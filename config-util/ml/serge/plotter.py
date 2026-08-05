#!/usr/bin/env python3
import json
import sys
import time
import threading
import math
from typing import Dict, List, Tuple, Optional
import os

# Try to import mouse libraries
try:
    import pyautogui
    MOUSE_AVAILABLE = True
except ImportError:
    MOUSE_AVAILABLE = False
    print("Note: Install pyautogui for mouse tracking: pip install pyautogui")

class TerminalMousePlot:
    def __init__(self, json_file: str, width: int = 80, height: int = 30):
        """Initialize terminal plot with mouse projection."""
        self.width = width
        self.height = height
        self.data_points = []  # List of (x, y, label)
        self.mouse_x = 0
        self.mouse_y = 0
        self.projected_x = 0
        self.projected_y = 0
        self.closest_label = None
        self.closest_distance = float('inf')
        self.running = True
        self.screen_width = 1920  # Default values
        self.screen_height = 1080
        
        # Get actual screen size if possible
        if MOUSE_AVAILABLE:
            try:
                self.screen_width, self.screen_height = pyautogui.size()
            except:
                pass
        
        self.load_data(json_file)
        
        # Start mouse tracking in background thread
        if MOUSE_AVAILABLE:
            self.mouse_thread = threading.Thread(target=self.track_mouse, daemon=True)
            self.mouse_thread.start()
        else:
            print("Mouse tracking disabled - using simulated mouse position")
    
    def load_data(self, filename: str):
        """Load and parse JSON data."""
        try:
            with open(filename, 'r') as f:
                data = json.load(f)
            
            # Handle your JSON structure
            if isinstance(data, dict) and "data" in data:
                points_dict = data["data"]
            else:
                points_dict = data
            
            for label, coords in points_dict.items():
                if isinstance(coords, list) and len(coords) == 2:
                    try:
                        x, y = float(coords[0]), float(coords[1])
                        self.data_points.append((x, y, str(label)))
                    except (ValueError, TypeError):
                        print(f"Warning: Skipping invalid point for label '{label}': {coords}")
            
            print(f"Loaded {len(self.data_points)} data points")
            
        except FileNotFoundError:
            print(f"Error: File '{filename}' not found!")
            sys.exit(1)
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON in '{filename}'!")
            sys.exit(1)
    
    def track_mouse(self):
        """Continuously track mouse position."""
        while self.running:
            try:
                x, y = pyautogui.position()
                self.mouse_x = x
                self.mouse_y = y
                
                # Calculate projection onto data space
                self.calculate_projection()
                
                # Find closest data point
                self.find_closest_point()
                
                time.sleep(0.05)  # 20Hz update
            except:
                time.sleep(1)
    
    def calculate_projection(self):
        """Project mouse screen coordinates to data space."""
        # Normalize mouse position to [0, 1] range
        norm_x = self.mouse_x / self.screen_width
        norm_y = 1.0 - (self.mouse_y / self.screen_height)  # Invert Y axis
        
        if not self.data_points:
            return
        
        # Get data bounds
        data_x = [p[0] for p in self.data_points]
        data_y = [p[1] for p in self.data_points]
        data_min_x, data_max_x = min(data_x), max(data_x)
        data_min_y, data_max_y = min(data_y), max(data_y)
        
        # Project normalized mouse to data space
        data_range_x = data_max_x - data_min_x
        data_range_y = data_max_y - data_min_y
        
        if data_range_x > 0:
            self.projected_x = data_min_x + norm_x * data_range_x
        else:
            self.projected_x = data_min_x
        
        if data_range_y > 0:
            self.projected_y = data_min_y + norm_y * data_range_y
        else:
            self.projected_y = data_min_y
    
    def find_closest_point(self):
        """Find the data point closest to projected mouse position."""
        if not self.data_points:
            return
        
        self.closest_distance = float('inf')
        self.closest_label = None
        
        for x, y, label in self.data_points:
            distance = math.sqrt((x - self.projected_x) ** 2 + (y - self.projected_y) ** 2)
            if distance < self.closest_distance:
                self.closest_distance = distance
                self.closest_label = label
    
    def create_plot(self):
        """Create terminal plot with data points and mouse projection."""
        if not self.data_points:
            return [" No data points loaded! "]
        
        # Get data bounds
        data_x = [p[0] for p in self.data_points]
        data_y = [p[1] for p in self.data_points]
        data_min_x, data_max_x = min(data_x), max(data_x)
        data_min_y, data_max_y = min(data_y), max(data_y)
        
        # Add padding
        x_range = data_max_x - data_min_x
        y_range = data_max_y - data_min_y
        
        if x_range == 0:
            x_range = 1
            data_min_x -= 0.5
            data_max_x += 0.5
        
        if y_range == 0:
            y_range = 1
            data_min_y -= 0.5
            data_max_y += 0.5
        
        # Create plot grid
        plot = [[' ' for _ in range(self.width)] for _ in range(self.height)]
        
        # Draw border
        for i in range(self.width):
            plot[0][i] = '─'
            plot[self.height-1][i] = '─'
        for i in range(self.height):
            plot[i][0] = '│'
            plot[i][self.width-1] = '│'
        plot[0][0] = '┌'
        plot[0][self.width-1] = '┐'
        plot[self.height-1][0] = '└'
        plot[self.height-1][self.width-1] = '┘'
        
        # Plot data points
        for x, y, label in self.data_points:
            # Convert data coordinates to plot coordinates
            plot_x = int((x - data_min_x) / x_range * (self.width - 3)) + 1
            plot_y = int((1 - (y - data_min_y) / y_range) * (self.height - 3)) + 1
            
            plot_x = max(1, min(self.width - 2, plot_x))
            plot_y = max(1, min(self.height - 2, plot_y))
            
            # Use different symbols for points
            plot[plot_y][plot_x] = '·'
        
        # Plot mouse projection point
        if MOUSE_AVAILABLE or (self.mouse_x > 0 and self.mouse_y > 0):
            proj_plot_x = int((self.projected_x - data_min_x) / x_range * (self.width - 3)) + 1
            proj_plot_y = int((1 - (self.projected_y - data_min_y) / y_range) * (self.height - 3)) + 1
            
            proj_plot_x = max(1, min(self.width - 2, proj_plot_x))
            proj_plot_y = max(1, min(self.height - 2, proj_plot_y))
            
            # Draw mouse cursor
            plot[proj_plot_y][proj_plot_x] = '✪'
            
            # Draw crosshair
            crosshair_size = 2
            for i in range(1, crosshair_size + 1):
                # Horizontal line
                if proj_plot_x + i < self.width - 1:
                    if plot[proj_plot_y][proj_plot_x + i] == ' ':
                        plot[proj_plot_y][proj_plot_x + i] = '─'
                if proj_plot_x - i > 0:
                    if plot[proj_plot_y][proj_plot_x - i] == ' ':
                        plot[proj_plot_y][proj_plot_x - i] = '─'
                
                # Vertical line
                if proj_plot_y + i < self.height - 1:
                    if plot[proj_plot_y + i][proj_plot_x] == ' ':
                        plot[proj_plot_y + i][proj_plot_x] = '│'
                if proj_plot_y - i > 0:
                    if plot[proj_plot_y - i][proj_plot_x] == ' ':
                        plot[proj_plot_y - i][proj_plot_x] = '│'
        
        # Add title
        title = " Dataset "
        title_pos = (self.width - len(title)) // 2
        for i, char in enumerate(title):
            if 0 <= title_pos + i < self.width:
                plot[0][title_pos + i] = char
        
        return plot
    
    # def print_status(self):
    #     """Print status information below the plot."""
    #     lines = []
        
    #     # Mouse information
    #     if MOUSE_AVAILABLE:
    #         lines.append(f"Mouse: ({self.mouse_x}, {self.mouse_y})")
    #     else:
    #         lines.append("Mouse: [pyautogui not installed]")
    #         lines.append(f"Simulated: ({self.mouse_x}, {self.mouse_y})")
        
    #     lines.append(f"Projected: ({self.projected_x:.3f}, {self.projected_y:.3f})")
        
    #     if self.closest_label:
    #         lines.append(f"Closest point: '{self.closest_label}' (distance: {self.closest_distance:.3f})")
        
    #     lines.append(f"Points: {len(self.data_points)}")
    #     lines.append("Press Ctrl+C to exit")
        
    #     return lines
    
    def simulate_mouse_movement(self):
        """Simulate mouse movement for testing without pyautogui."""
        import random
        if not MOUSE_AVAILABLE:
            # Move mouse in a circular pattern
            t = time.time()
            radius = 400
            center_x = self.screen_width // 2
            center_y = self.screen_height // 2
            
            self.mouse_x = center_x + int(radius * math.sin(t))
            self.mouse_y = center_y + int(radius * math.cos(t))
            
            self.calculate_projection()
            self.find_closest_point()
    
    def run(self, fps: int = 15):
        """Main animation loop."""
        print("\033[2J\033[H", end="")  # Clear screen
        
        print("=" * 60)
        print("DATASET")
        print("=" * 60)
        
        if not MOUSE_AVAILABLE:
            print("NOTE: pyautogui not installed - using simulated mouse movement")
            print("Install with: pip install pyautogui")
        
        print("\nMove your mouse to see projection in real-time!")
        print("Press Ctrl+C to exit")
        print("=" * 60)
        
        time.sleep(2)
        
        try:
            frame_time = 1.0 / fps
            frame_count = 0
            
            while self.running:
                # Update mouse position if not using pyautogui
                if not MOUSE_AVAILABLE:
                    self.simulate_mouse_movement()
                
                # Clear screen and move cursor to top
                print("\033[2J\033[H", end="")
                
                # Create and print plot
                plot = self.create_plot()
                for row in plot:
                    print(''.join(row))
                
                # Print status
                # print("\n" + "-" * self.width)
                # for line in self.print_status():
                #     print(line)
                
                # Update frame counter
                frame_count += 1
                
                # Wait for next frame
                time.sleep(frame_time)
                
        except KeyboardInterrupt:
            print("\n\nExiting...")
            self.running = False
        except Exception as e:
            print(f"\nError: {e}")
            self.running = False

def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python mouse_plot.py <json_file> [width] [height]")
        print("\nExample:")
        print("  python mouse_plot.py data.json")
        print("  python mouse_plot.py data.json 100 40")
        print("\nInstall pyautogui for actual mouse tracking:")
        print("  pip install pyautogui")
        sys.exit(1)
    
    json_file = sys.argv[1]
    width = int(sys.argv[2]) if len(sys.argv) > 2 else 80
    height = int(sys.argv[3]) if len(sys.argv) > 3 else 30
    
    # Create and run plotter
    plotter = TerminalMousePlot(json_file, width, height)
    plotter.run(fps=20)

if __name__ == "__main__":
    main()
