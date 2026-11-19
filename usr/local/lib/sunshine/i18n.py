"""Translations for the Python Sunshine tools: tr("English text") returns the text in the selected language (same rules and word list as ui.sh)."""
import os, re

_CONF = ("/etc/sunshine/tools.conf", os.path.expanduser("~/.config/sunshine/tools.conf"))
_DIR = os.environ.get("SUNSHINE_I18N", "/usr/share/sunshine/i18n")


def _setting(name, default):
    val = default
    for path in _CONF:              # the user file wins over the system file
        try:
            for line in open(path):
                m = re.match(r"%s=(.*)" % name, line.strip())
                if m and m.group(1).strip():
                    val = m.group(1).strip()
        except OSError:
            pass
    return val


def _language():
    lang = _setting("language", "auto")
    if lang != "auto":
        return lang
    env = os.environ.get("LC_ALL") or os.environ.get("LC_MESSAGES") or os.environ.get("LANG") or ""
    if env.startswith("uk"):
        return "uk"
    try:
        if re.search(r"^city=.*toulouse", open("/etc/sunshine/install-location").read(), re.I | re.M):
            return "uk"
    except OSError:
        pass
    return "en"


_T = {}
if _language() == "uk":
    try:
        for line in open(os.path.join(_DIR, "uk.tsv"), encoding="utf-8"):
            if "\t" in line:
                k, v = line.rstrip("\n").split("\t", 1)
                _T[k.replace("\\n", "\n")] = v.replace("\\n", "\n")
    except OSError:
        pass


def tr(text):
    return _T.get(text, text)
