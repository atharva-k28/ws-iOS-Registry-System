import os
import re

def replace_in_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    for old, new in replacements:
        content = re.sub(old, new, content)
        
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

def process_directory(directory):
    replacements = [
        (r'\.hostID', '.ownerUserId'),
        (r'\.eventDescription', '.eventType'), # temporary fallback since description is removed
        (r'\.eventDate', '.startDate'),
        (r'\.coverImageURL', '.coverImage'),
        (r'\.isPublic', '!(.isPrivate ?? true)'),
        (r'\.productDescription', '.description'),
        (r'\.imageURL', '.imageUrl'),
        (r'\.isAIRecommended', '(.isBestSeller ?? false)'),
        (r'\.eventID', '.registryId'),
        (r'\.productID', '.productId'),
        (r'\.targetAmount', '(.price * Double(.quantityNeeded ?? 1))'),
        (r'\.currentAmount', '(.fundedAmount ?? 0.0)'),
        (r'\.isPurchased', '((.fundedAmount ?? 0) >= (.price * Double(.quantityNeeded ?? 1)))'),
        (r'\.addedAt', '.createdAt'),
        (r'\.displayName', '.fullName'),
        (r'\.avatarURL', '.avatarUrl'),
        (r'\.bio', '""'),
        (r'Event\.mockList', 'MockData.events'),
        (r'Product\.mockList', 'MockData.products'),
        (r'RegistryItem\.mockList', 'MockData.registryItems'),
        (r'Event\.mock', 'MockData.events[0]'),
        (r'Product\.mock', 'MockData.products[0]'),
        (r'RegistryItem\.mock', 'MockData.registryItems[0]'),
        (r'User\.mock', 'MockData.currentUser')
    ]
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.swift'):
                filepath = os.path.join(root, file)
                replace_in_file(filepath, replacements)

if __name__ == "__main__":
    process_directory("/Users/sdc-user/Downloads/ws-iOS-Registry-System/iOS_Registry_System/Views")
    process_directory("/Users/sdc-user/Downloads/ws-iOS-Registry-System/iOS_Registry_System/ViewModels")
