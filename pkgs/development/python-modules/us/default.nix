{
  lib,
  buildPythonPackage,
  fetchPypi,
  jellyfish,
  pytestCheckHook,
  pythonOlder,
  pytz,
}:

buildPythonPackage rec {
  pname = "us";
  version = "3.2.0";
  format = "setuptools";

  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yyI+hTk9zFFx6tDdISutxH+WZ7I3AP6j5+pfMQ1UUzg=";
  };

  postPatch = ''
    # Upstream spins jellyfish
    substituteInPlace setup.py \
      --replace "jellyfish==" "jellyfish>="
  '';

  propagatedBuildInputs = [ jellyfish ];

  nativeCheckInputs = [
    pytestCheckHook
    pytz
  ];

  pythonImportsCheck = [ "us" ];

  meta = with lib; {
    description = "Package for easily working with US and state metadata";
    mainProgram = "states";
    longDescription = ''
      All US states and territories, postal abbreviations, Associated Press style
      abbreviations, FIPS codes, capitals, years of statehood, time zones, phonetic
      state name lookup, is contiguous or continental, URLs to shapefiles for state,
      census, congressional districts, counties, and census tracts.
    '';
    homepage = "https://github.com/unitedstates/python-us/";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
