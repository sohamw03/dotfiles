# Dotfiles

This repository contains my personal configuration files for bash. These dotfiles help to set up a consistent development environment across different systems.

## Files Included

- **.profile**: Executed by the command interpreter for login shells. Includes `.bashrc` if it exists and sets the PATH to include user's private bin directories.
- **.bashrc**: Executed by bash for non-login shells. Configures bash history, prompt, and enables color support for `ls` and other commands.

## Installation

To use these configuration files, follow these steps:

1. Clone the repository to your home directory:
   ```sh
   git clone https://github.com/sohamw03/dotfiles.git ~/dotfiles
   ```

2. Backup your existing dotfiles:
   ```sh
   mv ~/.profile ~/.profile_backup
   mv ~/.bashrc ~/.bashrc_backup
   ```

3. Create symbolic links to the new dotfiles:
   ```sh
   ln -s ~/dotfiles/.profile ~/.profile
   ln -s ~/dotfiles/.bashrc ~/.bashrc
   ```

4. Reload your shell:
   ```sh
   source ~/.profile
   source ~/.bashrc
   ```

## Usage

These dotfiles will automatically configure your bash environment upon login or when opening a new terminal session. You can customize them further by editing the files in the repository.

## Contributions

Feel free to fork the repository and submit pull requests with improvements or additional configurations.

## License

This repository is licensed under the Apache 2.0 License.
