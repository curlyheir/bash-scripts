import os

def generate_readme():
    # Configuration
    target_extension = '.sh'          # Look for shell scripts
    universal_icon = 'curly-heir-sh.jpg' # single icon for all .sh files
    
    readme_content = "# Shell Scripts\n\n| Preview | File Name |\n| :---: | :--- |\n"
    
    found_files = False
    
    # Check if the universal icon exists
    if not os.path.exists(universal_icon):
        print(f"Warning: {universal_icon} not found! Using emoji fallback.")
        universal_icon = "💻" # Fallback to emoji
        is_image = False
    else:
        is_image = True

    for file in os.listdir('.'):
        # Skip the script itself and the icon file to avoid listing them
        if file == 'generate_readme.py' or file == universal_icon:
            continue
            
        if file.endswith(target_extension):
            found_files = True
            
            if is_image:
                readme_content += f"| <img src='{universal_icon}' width='64'> | [{file}]({file}) |\n"
            else:
                readme_content += f"| 💻 | [{file}]({file}) |\n"

    if not found_files:
        readme_content = "# No shell scripts found in this directory."

    with open('README.md', 'w') as f:
        f.write(readme_content)

if __name__ == "__main__":
    generate_readme()   
