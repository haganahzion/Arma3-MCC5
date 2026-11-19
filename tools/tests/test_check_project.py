import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import check_project as cp  # noqa: E402

CFG = """class myCat
{
	#ifdef MCCMODE
	file = "\\mcc_sandbox_mod\\mcc\\fnc\\cat";
	#else
	file = "mcc\\fnc\\cat";
	#endif
	class good {};
	class missing {description = "x";};
};
"""


def make_repo(tmp_path, files):
    for rel, text in files.items():
        p = tmp_path / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text, encoding="utf-8")
    return tmp_path


def run(tmp_path):
    idx = cp.file_index(tmp_path)
    return cp.check_functions(tmp_path, idx), cp.check_paths(tmp_path, idx), cp.check_remote(tmp_path)


def test_clean_repo_has_no_problems(tmp_path):
    root = make_repo(tmp_path, {
        "mcc/cfg/cfgFunctions.hpp": CFG.replace("\tclass missing {description = \"x\";};\n", ""),
        "mcc/fnc/cat/fn_good.sqf": 'playSound3D ["\\mcc_sandbox_mod\\mcc\\sounds\\a.ogg", player];\n'
                                   '["x"] remoteExec ["MCC_fnc_good", 2];',
        "mcc/sounds/a.ogg": "",
        "mcc/cfg/CfgRemoteExec.hpp": "class MCC_fnc_good {allowedTargets=2;};",
    })
    assert run(root) == ([], [], [])


def test_missing_function_file_is_reported(tmp_path):
    root = make_repo(tmp_path, {"mcc/cfg/cfgFunctions.hpp": CFG, "mcc/fnc/cat/fn_good.sqf": ""})
    funcs, _, _ = run(root)
    assert len(funcs) == 1 and "MCC_fnc_missing" in funcs[0]


def test_missing_sound_path_is_reported(tmp_path):
    root = make_repo(tmp_path, {"mcc/x.hpp": 'sound[] = {"\\mcc_sandbox_mod\\mcc\\sounds\\wind0.5.ogg", 1, 1};'})
    _, paths, _ = run(root)
    assert len(paths) == 1 and "wind0.5.ogg" in paths[0]


def test_engine_paths_are_ignored(tmp_path):
    root = make_repo(tmp_path, {"mcc/x.hpp": 'icon = "\\A3\\ui_f\\data\\map\\mapcontrol\\bush_ca.paa";'})
    assert run(root)[1] == []


def test_unlisted_remote_target_is_reported(tmp_path):
    root = make_repo(tmp_path, {
        "mcc/a.sqf": '[1] remoteExecCall ["MCC_fnc_notListed", 0];\n// [1] remoteExec ["MCC_fnc_commented", 0];',
        "mcc/cfg/CfgRemoteExec.hpp": "class MCC_fnc_other {allowedTargets=0;};",
    })
    remote = run(root)[2]
    assert len(remote) == 1 and "MCC_fnc_notListed" in remote[0]


def test_whitelist_is_case_insensitive(tmp_path):
    root = make_repo(tmp_path, {
        "mcc/a.sqf": '[] remoteExec ["mcc_fnc_LOGIN", 2];',
        "mcc/cfg/CfgRemoteExec.hpp": "class MCC_fnc_login {allowedTargets=2;};",
    })
    assert run(root)[2] == []


def test_garbage_and_empty_files_do_not_crash(tmp_path):
    root = make_repo(tmp_path, {
        "mcc/cfg/cfgFunctions.hpp": "class { } } #endif #else {{ file = \"",
        "mcc/empty.sqf": "",
        "mcc/bin.sqf": "\x00\x01\x02 remoteExec [",
    })
    funcs, paths, remote = run(root)
    assert paths == [] and remote == []
    assert isinstance(funcs, list)


def test_main_exit_codes(tmp_path):
    clean = make_repo(tmp_path / "a", {"mcc/a.sqf": "hint 'x';"})
    assert cp.main(["x", str(clean)]) == 0
    broken = make_repo(tmp_path / "b", {"mcc/a.sqf": '[] remoteExec ["MCC_fnc_nope", 2];'})
    assert cp.main(["x", str(broken)]) == 1
