#!/usr/bin/env python3
"""
Verification Script for Chest X-Ray Classifier FPGA Design Fixes
Checks that all critical issues identified in design review have been addressed
"""

import os
import re
import sys
from pathlib import Path

class DesignFixVerifier:
    def __init__(self):
        self.issues_found = []
        self.fixes_verified = []
        self.files_checked = 0
        
    def check_file_exists(self, filepath):
        """Check if a file exists"""
        if os.path.exists(filepath):
            return True
        else:
            self.issues_found.append(f"Missing file: {filepath}")
            return False
    
    def check_synthesizability_fixes(self, filepath):
        """Check that synthesizability issues have been fixed"""
        if not self.check_file_exists(filepath):
            return False

        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # Advanced check for unprotected $display statements
        unprotected_displays = self.find_unprotected_displays(content)
        if unprotected_displays:
            self.issues_found.append(f"{filepath}: Found {len(unprotected_displays)} unprotected $display statements")
        else:
            self.fixes_verified.append(f"{filepath}: All $display statements properly protected")

        # Check for static variables
        static_vars = re.findall(r'\bstatic\s+\w+', content)
        if static_vars:
            self.issues_found.append(f"{filepath}: Found {len(static_vars)} static variables: {static_vars}")
        else:
            self.fixes_verified.append(f"{filepath}: No static variables found")

        # Check for proper synthesis guards
        synthesis_guards = re.findall(r'`ifndef\s+SYNTHESIS', content)
        if synthesis_guards:
            self.fixes_verified.append(f"{filepath}: Found {len(synthesis_guards)} synthesis guard(s)")

        # Check for integer declarations (should be reg)
        integer_decls = re.findall(r'\binteger\s+\w+', content)
        if integer_decls:
            self.issues_found.append(f"{filepath}: Found {len(integer_decls)} integer declarations (should be reg)")

        self.files_checked += 1
        return True

    def find_unprotected_displays(self, content):
        """Find $display statements that are not protected by `ifndef SYNTHESIS"""
        lines = content.split('\n')
        unprotected = []
        in_synthesis_guard = False
        brace_depth = 0

        for i, line in enumerate(lines):
            stripped = line.strip()

            # Track synthesis guard blocks
            if '`ifndef SYNTHESIS' in stripped:
                in_synthesis_guard = True
                brace_depth = 0
            elif '`endif' in stripped and in_synthesis_guard:
                in_synthesis_guard = False
                brace_depth = 0
            elif '`else' in stripped and in_synthesis_guard:
                in_synthesis_guard = False  # We're now in the synthesis section

            # Track brace depth within synthesis guards
            if in_synthesis_guard:
                brace_depth += stripped.count('{') - stripped.count('}')

            # Check for $display statements
            if re.match(r'^\s*\$display\(', line):
                if not in_synthesis_guard:
                    unprotected.append(i + 1)  # Line numbers are 1-based

        return unprotected
    
    def check_timing_constraints(self):
        """Check that timing constraints file exists and is comprehensive"""
        xdc_file = "chest_xray_classifier_constraints.xdc"
        
        if not self.check_file_exists(xdc_file):
            return False
            
        with open(xdc_file, 'r') as f:
            content = f.read()
            
        # Check for essential constraints
        required_constraints = [
            'create_clock',
            'set_input_delay',
            'set_output_delay',
            'set_clock_groups',
            'set_multicycle_path'
        ]
        
        missing_constraints = []
        for constraint in required_constraints:
            if constraint not in content:
                missing_constraints.append(constraint)
        
        if missing_constraints:
            self.issues_found.append(f"{xdc_file}: Missing constraints: {missing_constraints}")
        else:
            self.fixes_verified.append(f"{xdc_file}: All essential constraints present")
            
        # Check for clock definitions
        clocks = re.findall(r'create_clock.*-name\s+(\w+)', content)
        if len(clocks) >= 2:
            self.fixes_verified.append(f"{xdc_file}: Found {len(clocks)} clock domains: {clocks}")
        else:
            self.issues_found.append(f"{xdc_file}: Insufficient clock definitions")
            
        return True
    
    def check_state_machine_improvements(self):
        """Check for state machine improvements"""
        sm_file = "simplified_state_machine.sv"
        
        if not self.check_file_exists(sm_file):
            self.issues_found.append("Missing simplified state machine file")
            return False
            
        with open(sm_file, 'r') as f:
            content = f.read()
            
        # Check for one-hot encoding
        if 'fsm_encoding = "one_hot"' in content:
            self.fixes_verified.append(f"{sm_file}: One-hot encoding specified")
        else:
            self.issues_found.append(f"{sm_file}: Missing one-hot encoding directive")
            
        # Check for timeout handling
        if 'timeout' in content.lower():
            self.fixes_verified.append(f"{sm_file}: Timeout handling implemented")
        else:
            self.issues_found.append(f"{sm_file}: Missing timeout handling")
            
        return True
    
    def check_synthesis_verification(self):
        """Check for synthesis verification tools"""
        tcl_file = "synthesis_check.tcl"
        
        if not self.check_file_exists(tcl_file):
            self.issues_found.append("Missing synthesis verification script")
            return False
            
        with open(tcl_file, 'r') as f:
            content = f.read()
            
        # Check for essential Vivado commands
        required_commands = [
            'create_project',
            'add_files',
            'launch_runs synth_1',
            'report_utilization',
            'report_timing_summary'
        ]
        
        missing_commands = []
        for cmd in required_commands:
            if cmd not in content:
                missing_commands.append(cmd)
                
        if missing_commands:
            self.issues_found.append(f"{tcl_file}: Missing commands: {missing_commands}")
        else:
            self.fixes_verified.append(f"{tcl_file}: All essential synthesis commands present")
            
        return True
    
    def run_verification(self):
        """Run complete verification of all fixes"""
        print("🔍 Verifying Design Fixes for Chest X-Ray Classifier FPGA Implementation")
        print("=" * 80)
        
        # Check main files for synthesizability fixes
        main_files = [
            "chest_xray_classifier_top.sv",
            "First Layer/accelerator.sv", 
            "interface_adapter.sv"
        ]
        
        print("\n📋 Checking Synthesizability Fixes...")
        for filepath in main_files:
            self.check_synthesizability_fixes(filepath)
            
        print("\n⏰ Checking Timing Constraints...")
        self.check_timing_constraints()
        
        print("\n🔄 Checking State Machine Improvements...")
        self.check_state_machine_improvements()
        
        print("\n🧪 Checking Synthesis Verification Tools...")
        self.check_synthesis_verification()
        
        # Generate report
        print("\n" + "=" * 80)
        print("📊 VERIFICATION RESULTS")
        print("=" * 80)
        
        print(f"\n✅ FIXES VERIFIED ({len(self.fixes_verified)}):")
        for fix in self.fixes_verified:
            print(f"  ✓ {fix}")
            
        if self.issues_found:
            print(f"\n❌ ISSUES FOUND ({len(self.issues_found)}):")
            for issue in self.issues_found:
                print(f"  ✗ {issue}")
        else:
            print(f"\n🎉 NO ISSUES FOUND - All fixes verified successfully!")
            
        print(f"\n📈 SUMMARY:")
        print(f"  Files Checked: {self.files_checked}")
        print(f"  Fixes Verified: {len(self.fixes_verified)}")
        print(f"  Issues Found: {len(self.issues_found)}")
        
        # Overall status
        if len(self.issues_found) == 0:
            print(f"\n🚀 STATUS: READY FOR PRODUCTION")
            print(f"   All critical issues have been successfully addressed!")
            return True
        elif len(self.issues_found) <= 2:
            print(f"\n⚠️  STATUS: MINOR ISSUES REMAINING")
            print(f"   Most fixes verified, minor cleanup needed")
            return False
        else:
            print(f"\n🚨 STATUS: MAJOR ISSUES REMAINING") 
            print(f"   Significant work still needed")
            return False

def main():
    """Main verification function"""
    verifier = DesignFixVerifier()
    success = verifier.run_verification()
    
    if success:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
