# Directory Clean-Up Wizard

This PowerShell tool offers a dual-mode cleanup for your file system: select non-recursive for top-level empty directories or recursive for a deep clean, including nested empty folders. Tailored for efficient organization, it adapts to various cleanup preferences.

## Features

- **Mode Selection for Deletion Method**: Users can select either non-recursive deletion to remove top-level empty folders or recursive deletion for a comprehensive cleanup that includes all nested empty folders.
- **User Interaction**: Prompts the user for the directory path to be cleaned, requiring confirmation to proceed with the deletion process.
- **Progress Tracking**: Real-time visual display of the deletion progress through a secondary script.
- **Logging**: Detailed logging of the operation, including start and end times, total folders evaluated, and specifics of each folder deletion.

## Prerequisites

Before running this script, ensure you have:
- PowerShell 5.1 or higher installed on your system.
- Necessary permissions to access and modify the folders you wish to evaluate and potentially delete.

## Installation

Follow these steps to prepare the script for execution:

1. Download the script files `RemoveEmptyFolderScript.ps1` and `ProgressDisplayScript.ps1` to your preferred location on your machine.
2. Ensure both scripts are saved in the same directory for them to interact properly.

## Usage

To run the script, execute the following steps:

1. Open a PowerShell prompt with administrative privileges.
2. Change your directory (`cd`) to where the scripts are located.
3. Launch the script by entering:
    ```powershell
    .\RemoveEmptyFolderScript.ps1
    ```
4. Upon execution, the script prompts users to choose the deletion method.
    - For non-recursive deletion, it efficiently removes empty top-level folders.
    - The recursive option performs a deep clean by removing all empty folders, including nested ones.
4. When prompted, input the full path of the root directory you wish to clean up from empty folders.
5. Confirm your input by typing `y` to start the deletion process or `n` to cancel.

### Operational Flow

- The script initiates by asking for the root path to check and for user confirmation to proceed.
- It sets up a logging system and a progress display script to track and report the operation's progress in real time.
- The main functionality involves recursively checking each folder and its subfolders to identify and remove those without any files.
- Post-operation, it logs a summary of the actions taken, including the total number of folders processed and deleted, and then cleanly exits by closing the progress display and deleting temporary files.

## Logging

The operation generates logs within a `logs` directory situated in the script's running location. Each log file is named after the operation's start date and time, facilitating easy identification and review. Logs detail the deletion of empty folders and provide a summary of the operation for record-keeping purposes.

## Contributing

Your contributions are welcome to enhance the script's functionality or address any issues. To contribute:

1. Fork the repository.
2. Create a new branch for your updates.
3. Submit your changes with detailed commit messages.
4. Create a pull request against the main branch, describing your improvements or fixes.

Ensure your contributions are well-documented and follow the existing coding standards.

## License

This script is made available "as is", with no warranties. Users are free to use, modify, and distribute it according to their needs.

For support or to report issues, please open an issue on the GitHub project page.
