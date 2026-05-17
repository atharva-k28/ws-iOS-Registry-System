import os

def fix_deprecation(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.swift'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                if 'SupabaseManager.shared.client.database' in content:
                    content = content.replace('SupabaseManager.shared.client.database', 'SupabaseManager.shared.client')
                    with open(path, 'w') as f:
                        f.write(content)
                    print(f"Fixed deprecation in {path}")

fix_deprecation('/Users/sdc-user/Downloads/ws-iOS-Registry-System/iOS_Registry_System')
