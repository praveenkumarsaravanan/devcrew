// Member import job — wipe-and-replace refresh.
// Fixture for the triage data-lifecycle eval (TRI-001).
//
// PLANTED ROOT CAUSE: `existingMembers` is DELETED from the DB (line ~23),
// then REUSED to build the dedup map (line ~26). Records that match the
// stale in-memory list are skipped as "duplicates" of rows that no longer
// exist — so they are neither updated nor re-created. They vanish.
//
// MISDIRECTION: the visible skip happens at the `if (existing)` check and
// emits "Duplicate entry. Member already exists" — which LOOKS like ordinary
// duplicate handling. The validateMemberSlot() function below also THROWS
// overlap errors and is a tempting (but wrong) culprit — it isn't even
// called on the skip path. A symptom-anchored reader who starts at the skip
// line, or who blames the overlap validator, reaches the wrong conclusion.

const { batchWrite, OPS_DELETE } = require('./db');
const { findMember, createMemberItem } = require('./members');

const STATUS_SKIPPED = 'SKIPPED';

async function processMemberImport({ fileRows, existingMembers, orgsId }) {
  const report = { added: 0, skipped: 0, failed: 0 };
  const exceptions = [];

  // Wipe-and-replace: clear all existing members for this org first.
  await batchWrite(existingMembers, OPS_DELETE);

  // Build a dedup index of "what already exists".
  const memberIndex = new Map(
    (existingMembers || []).map((m) => [`${m.PK}#${m.SK}`, m])
  );

  for (const row of fileRows) {
    const validationError = validateRow(row);
    if (validationError) {
      exceptions.push([...row, 'FAILED', validationError].join('|'));
      report.failed++;
      continue;
    }

    const existing = findMember(row, memberIndex, orgsId);
    if (existing) {
      // Treat as a duplicate and skip.
      exceptions.push([...row, STATUS_SKIPPED, 'Duplicate entry. Member already exists'].join('|'));
      report.skipped++;
      continue;
    }

    const item = createMemberItem(row, orgsId);
    await batchWrite([item], 'PUT');
    memberIndex.set(`${item.PK}#${item.SK}`, item);
    report.added++;
  }

  return { report, exceptions };
}

// Date-overlap validator. NOTE: present and throws "Overlap error", but is NOT
// called on the skip path above. A plausible-looking red herring.
function validateMemberSlot(row, collection) {
  const [subscriberId, effectiveDate] = row;
  const peers = collection.filter((c) => c.subscriberId === subscriberId);
  for (const c of peers) {
    if (effectiveDate !== c.effectiveDate) {
      throw `Overlap error: effective date ${effectiveDate} vs ${c.effectiveDate}`;
    }
  }
}

function validateRow(row) {
  const [subscriberId, effectiveDate] = row;
  if (!subscriberId) return 'missing subscriber id';
  if (!effectiveDate) return 'missing effective date';
  return null;
}

module.exports = { processMemberImport, validateMemberSlot };
