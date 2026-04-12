#!/usr/bin/env python3
"""
Remove Firestore businesses whose `name` contains the substring "New Business",
along with related documents:

 - menu_items (via menu_id for each linked menu)
  - menus (via business.menu_id and/or menus.business_id == business id)
  - addresses (via business.address_id)
  - business_users (via business_id)
  - categories (via business_id)

Consumer accounts live in the `users` collection and are not linked to
`businesses` in this app's schema. This script deletes `business_users` only.
If you store staff elsewhere, extend the script.

Prerequisites:
  pip install firebase-admin
  Change firebase permissions to allow the service account to write to the database

Usage:
  set GOOGLE_APPLICATION_CREDENTIALS=path\\to\\service-account.json
  python remove_new_businesses.py --project-id nomnom-safe

Dry run (no writes):
  python remove_new_businesses.py --project-id nomnom-safe --dry-run

This script is not executed automatically; review and run manually when ready.
"""

from __future__ import annotations

import argparse
import sys
from typing import Any
import os

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError as e:
    print("Install firebase-admin: pip install firebase-admin", file=sys.stderr)
    raise SystemExit(1) from e

NAME_SUBSTRING = "New Business"
BATCH_LIMIT = 450  # stay under Firestore's 500 ops/batch limit
CREDENTIALS_PATH = "../serviceAccountKey.json"

if not os.path.exists(CREDENTIALS_PATH):
    raise FileNotFoundError(f"Service account file not found: {CREDENTIALS_PATH}")

def init_app(project_id: str | None) -> firestore.Client:
    cred = credentials.Certificate(CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred, {"projectId": project_id})
    return firestore.client()


def commit_batches(db: firestore.Client, refs: list[Any], dry_run: bool) -> None:
    """Delete document references in batches."""
    if not refs:
        return
    if dry_run:
        print(f"  [dry-run] Would delete {len(refs)} document(s)")
        for r in refs:
            print(f"    - {r.path}")
        return

    batch = db.batch()
    count = 0
    for ref in refs:
        batch.delete(ref)
        count += 1
        if count >= BATCH_LIMIT:
            batch.commit()
            batch = db.batch()
            count = 0
    if count:
        batch.commit()


def collect_menu_ids_for_business(
    db: firestore.Client, business_id: str, business_data: dict[str, Any]
) -> set[str]:
    ids: set[str] = set()
    mid = business_data.get("menu_id")
    if isinstance(mid, str) and mid.strip():
        ids.add(mid.strip())

    menus_q = db.collection("menus").where("business_id", "==", business_id).stream()
    for snap in menus_q:
        ids.add(snap.id)
    return ids


def delete_menu_items_for_menu(db: firestore.Client, menu_id: str, dry_run: bool) -> None:
    refs: list[Any] = []
    q = db.collection("menu_items").where("menu_id", "==", menu_id).stream()
    for snap in q:
        refs.append(snap.reference)
    commit_batches(db, refs, dry_run)


def delete_menus(db: firestore.Client, menu_ids: set[str], dry_run: bool) -> None:
    refs = [db.collection("menus").document(mid) for mid in menu_ids]
    commit_batches(db, refs, dry_run)


def delete_business_users(db: firestore.Client, business_id: str, dry_run: bool) -> None:
    refs: list[Any] = []
    q = db.collection("business_users").where("business_id", "==", business_id).stream()
    for snap in q:
        refs.append(snap.reference)
    commit_batches(db, refs, dry_run)


def delete_categories(db: firestore.Client, business_id: str, dry_run: bool) -> None:
    refs: list[Any] = []
    q = db.collection("categories").where("business_id", "==", business_id).stream()
    for snap in q:
        refs.append(snap.reference)
    commit_batches(db, refs, dry_run)


def delete_address(db: firestore.Client, address_id: str | None, dry_run: bool) -> None:
    if not address_id or not str(address_id).strip():
        return
    ref = db.collection("addresses").document(str(address_id).strip())
    commit_batches(db, [ref], dry_run)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--project-id",
        required=True,
        help="GCP / Firebase project id (e.g. nomnom-safe)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print actions without deleting anything",
    )
    args = parser.parse_args()

    db = init_app(args.project_id)

    targets: list[tuple[str, dict[str, Any]]] = []
    for snap in db.collection("businesses").stream():
        data = snap.to_dict() or {}
        name = data.get("name")
        if isinstance(name, str) and NAME_SUBSTRING in name:
            targets.append((snap.id, data))

    if not targets:
        print(f'No businesses found with "{NAME_SUBSTRING}" in name.')
        return

    print(f"Found {len(targets)} business(es) to remove:")
    for bid, data in targets:
        print(f"  - {bid}: {data.get('name')!r}")

    for business_id, business_data in targets:
        print(f"\nProcessing business {business_id}...")
        menu_ids = collect_menu_ids_for_business(db, business_id, business_data)
        print(f"  Menus to remove: {sorted(menu_ids) if menu_ids else '(none)'}")

        for mid in sorted(menu_ids):
            print(f"  Deleting menu_items for menu_id={mid}")
            delete_menu_items_for_menu(db, mid, args.dry_run)

        if menu_ids:
            print("  Deleting menu documents")
            delete_menus(db, menu_ids, args.dry_run)

        print("  Deleting business_users")
        delete_business_users(db, business_id, args.dry_run)

        print("  Deleting categories")
        delete_categories(db, business_id, args.dry_run)

        aid = business_data.get("address_id")
        if aid:
            print(f"  Deleting address {aid}")
            delete_address(db, str(aid).strip(), args.dry_run)

        print("  Deleting business document")
        commit_batches(db, [db.collection("businesses").document(business_id)], args.dry_run)

    print("\nDone.")


if __name__ == "__main__":
    main()
