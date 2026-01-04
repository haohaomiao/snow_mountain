from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


PORTRAIT_DEFAULT = 0
PORTRAIT_SMILE = 1
PORTRAIT_SAD = 2
PORTRAIT_UNEXPECTED = 3


_ELLIPSIS_ONLY_RE = re.compile(r"^[\s.。…·—\-–()（）]+$")


@dataclass(frozen=True)
class PortraitRuleSet:
	smile_keywords: tuple[str, ...]
	sad_keywords: tuple[str, ...]
	unexpected_keywords: tuple[str, ...]


RULES = PortraitRuleSet(
	smile_keywords=(
		# English
		"laugh",
		"can't wait",
		"good to hear",
		"happy",
		"incredible",
		"truly fallen in love",
		"sounds good",
		"classic",
		"i'd like that very much",
		"enjoy",
		"beautiful",
		# Chinese
		"哈哈",
		"（哈哈",
		"（笑",
		"笑）",
		"高兴",
		"开心",
		"妙不可言",
		"爱上",
		"经典",
		"足够经典",
		"说定了",
		"当然",
		"太好了",
		"真好",
		"很乐意",
		"我很乐意",
		"期待",
		"愿",
		"漂亮",
	),
	sad_keywords=(
		# English
		"(silence)",
		"sigh",
		"injury",
		"wound",
		"retire",
		"leaving",
		"leave tomorrow",
		"unhappy",
		"no point",
		"done drinking",
		"cry",
		"tears",
		# Chinese
		"（沉默）",
		"沉默",
		"唉",
		"受伤",
		"伤口",
		"退役",
		"离开",
		"不喝了",
		"没机会",
		"没有意义",
		"难过",
		"眼泪",
		"流泪",
		"哭",
		"不争气",
		"快要过去",
	),
	unexpected_keywords=(
		# English
		"suddenly",
		"damn",
		"didn't expect",
		"wouldn't expect",
		"surprised",
		"strange",
		"huh",
		"how did you know",
		# Chinese
		"突然",
		"见鬼",
		"没想到",
		"你怎么知道",
		"怎么知道",
		"神秘",
		"奇怪",
		"惊讶",
		"意外",
	),
)


def choose_portrait(text: str) -> int:
	t = (text or "").strip()
	if not t:
		return PORTRAIT_DEFAULT

	# Hard stops: silence / ellipsis-only lines
	if t in {"…", "……", "...", "..", "."}:
		return PORTRAIT_SAD
	if _ELLIPSIS_ONLY_RE.match(t) and ("…" in t or "..." in t or t.count(".") >= 3):
		return PORTRAIT_SAD

	# Scores (small set, high-signal)
	score_smile = 0
	score_sad = 0
	score_unexp = 0

	if "?" in t or "？" in t:
		score_unexp += 3
	if "!" in t or "！" in t:
		score_smile += 1

	# Prefix cues
	if t.startswith("唉"):
		score_sad += 4
	if t.startswith("呵"):
		score_smile += 2

	tl = t.lower()

	for kw in RULES.smile_keywords:
		if kw in tl or kw in t:
			score_smile += 2

	for kw in RULES.sad_keywords:
		if kw in tl or kw in t:
			score_sad += 3

	for kw in RULES.unexpected_keywords:
		if kw in tl or kw in t:
			score_unexp += 2

	# Tie-break priority: SAD > UNEXPECTED > SMILE > DEFAULT
	best = PORTRAIT_DEFAULT
	best_score = 0
	for portrait, score in (
		(PORTRAIT_SAD, score_sad),
		(PORTRAIT_UNEXPECTED, score_unexp),
		(PORTRAIT_SMILE, score_smile),
	):
		if score > best_score:
			best = portrait
			best_score = score
	return best


_EXT_DIALOGUE_LINE_RE = re.compile(
	r'^\[ext_resource\s+type="Script"\s+[^]]*path="res://scenes/bar/dialogue/dialogue_line\.gd"\s+id="([^"]+)"\]\s*$'
)
_SUB_RESOURCE_START_RE = re.compile(r'^\[sub_resource\s+type="Resource"\s+id="([^"]+)"\]\s*$')
_SCRIPT_LINE_RE = re.compile(r'^script\s*=\s*ExtResource\("([^"]+)"\)\s*$')
_TEXT_LINE_RE = re.compile(r'^text\s*=\s*(.*)\s*$')
_PORTRAIT_LINE_RE = re.compile(r'^portrait\s*=\s*(\d+)\s*$')


def _extract_text_value(text_line: str) -> str:
	# Expected: text = "..."
	m = _TEXT_LINE_RE.match(text_line.strip())
	if not m:
		return ""
	raw = m.group(1).strip()
	if raw.startswith('"') and raw.endswith('"') and len(raw) >= 2:
		return raw[1:-1]
	return raw


def _apply_portraits_to_dialogue_act(path: Path) -> tuple[bool, int]:
	data = path.read_bytes()
	text = data.decode("utf-8")
	if 'script_class="DialogueAct"' not in text:
		return (False, 0)

	newline = "\r\n" if "\r\n" in text else "\n"
	lines = text.splitlines(keepends=True)

	dialogue_line_ext_ids: set[str] = set()
	for ln in lines:
		m = _EXT_DIALOGUE_LINE_RE.match(ln.strip())
		if m:
			dialogue_line_ext_ids.add(m.group(1))

	changed = False
	lines_touched = 0

	i = 0
	while i < len(lines):
		if not lines[i].startswith("[sub_resource"):
			i += 1
			continue

		start = i
		i += 1
		while i < len(lines) and not lines[i].startswith("["):
			i += 1
		end = i
		block = list(lines[start:end])

		# Confirm this sub-resource is a DialogueLine
		script_ext_id = None
		for bl in block:
			sm = _SCRIPT_LINE_RE.match(bl.strip())
			if sm:
				script_ext_id = sm.group(1)
				break
		if script_ext_id is None or script_ext_id not in dialogue_line_ext_ids:
			lines[start:end] = block
			continue

		text_line_index = None
		text_value = ""
		for j, bl in enumerate(block):
			if bl.lstrip().startswith("text = "):
				text_line_index = j
				text_value = _extract_text_value(bl)
				break
		if text_line_index is None:
			lines[start:end] = block
			continue

		portrait_value = choose_portrait(text_value)
		lines_touched += 1

		portrait_line_index = None
		for j, bl in enumerate(block):
			if bl.lstrip().startswith("portrait = "):
				portrait_line_index = j
				break

		desired_line = f"portrait = {portrait_value}{newline}"

		if portrait_line_index is not None:
			if block[portrait_line_index] != desired_line:
				block[portrait_line_index] = desired_line
				changed = True
		else:
			insert_at = None
			for j, bl in enumerate(block):
				if bl.lstrip().startswith("speaker = "):
					insert_at = j + 1
					break
			if insert_at is None:
				for j, bl in enumerate(block):
					if bl.lstrip().startswith("script = "):
						insert_at = j + 1
						break
			if insert_at is None:
				insert_at = 1
			block.insert(insert_at, desired_line)
			changed = True

		lines[start:end] = block

	if changed:
		path.write_bytes("".join(lines).encode("utf-8"))
	return (changed, lines_touched)


def main() -> None:
	root = Path("acts")
	if not root.exists():
		raise SystemExit("Missing `acts/` directory (run from project root).")

	act_paths = sorted(root.rglob("*.tres"))
	files_changed = 0
	lines_touched_total = 0

	for path in act_paths:
		changed, lines_touched = _apply_portraits_to_dialogue_act(path)
		if changed:
			files_changed += 1
		lines_touched_total += lines_touched

	print(f"DialogueLine sub-resources processed: {lines_touched_total}")
	print(f"Files changed: {files_changed}")


if __name__ == "__main__":
	main()

