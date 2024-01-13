# Mantic Ubuntu Setup Script

## Overview
This script is an all-in-one solution for setting up Mantic Ubuntu with essential software while enhancing the system's usability and performance. It focuses on native integration and compatibility, offering an alternative to Snap-based applications which often lack these key aspects.

## Key Features
- **Selective Software Installation:** Easy installation of popular applications like Brave browser, Visual Studio Code, Spotify, and others.
- **Snap Removal:** Removes Snap to favor applications with better system integration and performance.
- **GNOME Customization:** Enhances the GNOME desktop environment for improved usability.
- **User Interface Optimization:** Modifies the desktop layout to resemble more traditional desktop environments.

## Prerequisites
- A Mantic Ubuntu installation.
- User with `sudo` privileges.

## Installation and Usage
1. **Clone or Download:**
   ```bash
   git clone [repository-url]
   cd [repository-name]
   ```
2. **Make the Script Executable:**
   ```bash
   chmod +x setup_script.sh
   ```
3. **Run the Script:**
   ```bash
   ./setup_script.sh
   ```

Follow the on-screen prompts to install packages, customize GNOME, and remove Snap.

## The Case Against Snap
Our script specifically targets the removal of Snap due to its limitations:
- **Lack of Native Integration:** Snap applications often run in a confined environment, leading to inconsistent user experiences and integration issues with the rest of the system.
- **Performance Overhead:** Snap packages can be slower to start and use more system resources compared to natively installed applications.
- **Automatic Updates:** While convenient, Snap's automatic updates can be disruptive and lack transparency.

By removing Snap, our script aims to enhance system performance and user control over application management.

## Acknowledgments
- Thanks to the vibrant Mantic Ubuntu community for their ongoing support and contributions.
- Special thanks to the power of AI: Assisting talentless hacks in crafting well-documented and functioning code!

## License
This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.
