# Nudge My Window

Window size and position management scripts for use with keyboard-based launchers like LaunchBar and Alfred.

## Testing

Open the `test.applescript` file with Apple’s Script Editor and press the run button. This will run through all built-in commands while speaking the name of each command as it is performed.

## Building

Open the `build.applescript` file with Apple’s Script Editor and press the run button. This will create individual script files for all commands to manipulate windows with.

A dialog appears when the process is finished.

## Installation

Once the build process has finished, you will find the script files you can use with LaunchBar or Alfred in the Commands directory that is created in the directory of this project.

The script files are stand-alone so you can place them wherever you want.

## Usage

Select one of the script files in the Commands directory with LaunchBar or Alfred and run them.

In LaunchBar for example, you could teach the abbreviation `nul` to select the script `Nudge My Window - left.scpt` or `nuot` to select the script `Nudge My Window - One Third Top.scpt`.

Keep in mind that LaunchBar has the instant send feature where pressing and holding the last character of an abbreviation.

## Multiple Screens

Nudge My Window is designed to only work on the screen where the mouse pointer currently resides.

So, for example, if you have the topmost window of your frontmost application on the second screen but the mouse pointer is currently on the first screen then the window will be transferred over to the first screen.

## Built-in Commands

All built-in commands act on the topmost window of the frontmost application.

The most basic command is named `full` and simply resizes the window to fill the screen.

Please note that in the context of Nudge My Window the screen is defined as the area below the menu bar and if applicable minus the height or width taken up by the Dock.

### Screen Halves

`left` Left screen half  
`right` Right screen half  
`top` Top screen half  
`bottom` Bottom screen half

### Quadrants

`1` Upper left screen quadrant  
`2` Upper right screen quadrant  
`3` Lower left screen quadrant  
`4` Lower right screen quadrant

#### Quadrant Halves

Each quadrant can be subdivided into its left, right, top, and bottom half.

The following examples also apply to quadrants 2, 3, and 4.

`1 left` Left half of quadrant 1  
`1 right` Right half of quadrant 1  
`1 top` Top half of quadrant 1  
`1 bottom` Bottom half of quadrant 1

#### Sub-Quadrants

Each quadrant can be subdivided into its sub-quadrants.

The following examples also apply to quadrants 2, 3, and 4.

`1 sub 1` Sub-quadrant 1 of quadrant 1  
`1 sub 2` Sub-quadrant 2 of quadrant 1  
`1 sub 3` Sub-quadrant 3 of quadrant 1  
`1 sub 4` Sub-quadrant 4 of quadrant 1

### Columns

Windows can be arranged in one of four columns name `a`, `b`, `c`, and `d`.

### Thirds

Here, the window is resized to either a third of the horizontal OR vertical screen size. The perpendicular side of the window is always resized to fill the screen.

In other words, the window is either resized to be a column or a row.

`one third left` Left column  
`one third horizontal center` Center column  
`one third right` Right column  
`one third top` Top row  
`one third vertical center` Middle row  
`one third bottom` Bottom row

### Thirds Subdivision

Each third can be subdivided into a top or bottom half.

`one third left top`  
`one third left bottom`  
`one third center top`  
`one third center bottom`  
`one third right top`  
`one third right bottom`  

### Repositioning

`center` Position window at the screen’s center without resizing it  

The following commands push the window to respective screen side.

`push left`  
`push right`  
`push top`  
`push bottom`  

The following commands move the window by 1/8th of the screen's width or height.

`move left`  
`move right`  
`move top`  
`move bottom`  

### Resizing

These commands resize the window while keeping it position.

`max width`  
`max height`  
`half width`  
`half height`  
`double width`  
`double height`  
`third width`  
`third height`  

The grow and shrink commands use 1/8th of the screen's width or height to resize the window.

`grow width`  
`shrink width`  
`grow height`  
`shrink height`  
`grow horizontally`  
`shrink horizontally`  
`grow vertically`  
`shrink vertically`  

## Additional Commands

The `Additional Commands` directory within `Source` holds scripts that are meant to be used with more than one window.

`auxiliary left`  
Places the window behind the topmost window on the left as an auxiliary window and the topmost window to the right.

`auxiliary right`  
Places the window behind the topmost window on the right as an auxiliary window and the topmost window to the left.

`browser quadrants`  
Places the topmost windows of Safari, Chrome, Firefox, and Brave in each screen’s quadrant.

`four columns`  
Organizes the four topmost windows into columns.

`quadrants`  
Organizes the four topmost windows into quadrants.

`three columns`  
Organizes the three topmost windows into columns.
