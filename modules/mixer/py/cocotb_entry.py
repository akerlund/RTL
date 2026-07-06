import importlib
import os
import pkgutil

import tc


def _export_tests():
  selected_module = os.environ.get("RTL_COCOTB_TEST_MODULE")
  module_names = [selected_module] if selected_module else [
    module_info.name for module_info in pkgutil.iter_modules(tc.__path__, "tc.")
  ]

  for module_name in module_names:
    module = importlib.import_module(module_name)
    for name, value in vars(module).items():
      if name.startswith(("tc_", "tb_")):
        globals()[name] = value


_export_tests()
del _export_tests
