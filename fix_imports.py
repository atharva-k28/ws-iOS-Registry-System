import os

def fix_imports(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.swift'):
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                if 'SupabaseManager.shared.client' in content and 'import Supabase' not in content:
                    # add import Supabase after import Foundation or import SwiftUI
                    if 'import SwiftUI' in content:
                        content = content.replace('import SwiftUI', 'import SwiftUI\nimport Supabase', 1)
                    elif 'import Foundation' in content:
                        content = content.replace('import Foundation', 'import Foundation\nimport Supabase', 1)
                    else:
                        content = 'import Supabase\n' + content
                        
                    with open(path, 'w') as f:
                        f.write(content)
                    print(f"Added import Supabase to {path}")

fix_imports('/Users/sdc-user/Downloads/ws-iOS-Registry-System/iOS_Registry_System')
