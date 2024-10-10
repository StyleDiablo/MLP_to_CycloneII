import os

def copy_to_mif(txt_file, mif_file):
  """
  Copies a txt file to a mif file.

  Args:
      txt_file: Path to the txt file.
      mif_file: Path to the output mif file.
  """
  with open(txt_file, "rb") as txt:
    data = txt.read()

  with open(mif_file, "wb") as mif:
    mif.write(data)

  print(f"Copied {txt_file} to {mif_file} (as .mif)")

directory = "w_b"

for filename in os.listdir(directory):
  if filename.endswith(".txt"):
    txt_path = os.path.join(directory, filename)
    mif_path = os.path.splitext(txt_path)[0] + ".mif"

    copy_to_mif(txt_path, mif_path)

print("Copy operation completed!")
