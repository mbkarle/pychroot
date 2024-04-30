import os
import sys
import shutil

def path_suffix(s1, s2):
  if len(s2) < len(s2):
    return path_suffix(s2, s1)

  return s2[len(s1):].lstrip('/')


def init_jail(app_dir, jail_dir):
  warden_relative = path_suffix(app_dir, os.getcwd())
  jail_relative = path_suffix(app_dir, jail_dir)
  
  def ignore_jail(path, listdir):
    if path == app_dir:
      return (jail_relative, '.git', warden_relative)

    return []


  # for every element on path, copy to jail
  for p in sys.path:
    if p == os.getcwd():
      p = app_dir
    try:
      shutil.copytree(p, f'{jail_dir}/{p}', ignore=ignore_jail, dirs_exist_ok=True)
    except FileNotFoundError:
      print(f'Skipping file/directory not found: {p}')
        

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} <path/to/app> <path/to/jail>")
        sys.exit(1)
    init_jail(os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2]))
