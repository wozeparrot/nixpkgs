{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, click
, click-default-group
, dateutils
, sqlite-fts4
, tabulate
, pytestCheckHook
, hypothesis
}:

buildPythonPackage rec {
  pname = "sqlite-utils";
  version = "3.19";
  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "509099fce5f25faada6e76b6fb90e8ef5ba0f1715177933a816718be0c8e7244";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '"pytest-runner"' ""
  '';

  propagatedBuildInputs = [
    click
    click-default-group
    dateutils
    sqlite-fts4
    tabulate
  ];

  checkInputs = [
    pytestCheckHook
    hypothesis
  ];

  meta = with lib; {
    description = "Python CLI utility and library for manipulating SQLite databases";
    homepage = "https://github.com/simonw/sqlite-utils";
    license = licenses.asl20;
    maintainers = with maintainers; [ meatcar ];
  };
}
