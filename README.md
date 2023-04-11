# Nudge My Window

Window size and position management scripts for use with keyboard-based launchers like LaunchBar and Alfred.

## Testing

Open the `test.applescript` file with Apple’s Script Editor and press the **Run** button. This will perform all built-in commands while speaking the name of each command as it’s nudging the window.

## Building

Open the `build.applescript` file with Apple’s Script Editor and press the **Run** button. This will create individual script files for all commands to manipulate windows with.

A dialog appears when the process is finished.

## Installation

Once the build process has finished, you will find the script files you can use with LaunchBar or Alfred in the `Build` directory that is created in the project's directory.

The script files are self-contained so you can place them wherever you want.

### Automatic Installation

Using the shell, you can specify a directory path you wish to automatically install the script files to.

```
defaults write de.adriannier.NudgeMyWindow installLocation "~/path/to/directory"
```

To clear this setting, use the following command:

```
defaults delete de.adriannier.NudgeMyWindow installLocation
```

## Usage

Select one of the script files in the `Build` directory or in the installed location with LaunchBar or Alfred and run it.

In LaunchBar for example, you could teach the abbreviation `nul` to select the script `Nudge My Window - left.scpt` or `nuot` to select the script `Nudge My Window - One Third Top.scpt`.

Keep in mind that LaunchBar has the [Instant Open](https://www.obdev.at/resources/launchbar/help/InstantOpen.html) feature: Pressing and holding the last character of an abbreviation immediately runs the script.

## What’s a Screen?

In the context of Nudge My Window the screen is defined as the area below the menu bar and if applicable minus the height or width taken up by the Dock.

## Multiple Screens

While Nudge My Window supports multiple screens, it is designed to choose the screen where the mouse pointer currently resides as the target for the re-arranged window.

So, for example, if you have the topmost window of your frontmost application on the second screen, but the mouse pointer is currently on the first screen, then the window will be arranged on the first screen.

## Built-in Commands

All built-in commands act on the topmost window of the frontmost application.

The most basic command is named `full` and simply resizes the window to fill the screen.

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

`1 left` Left half of quadrant 1  
`1 right` Right half of quadrant 1  
`1 top` Top half of quadrant 1  
`1 bottom` Bottom half of quadrant 1

These examples also apply to quadrants 2, 3, and 4.

#### Sub-Quadrants

Each quadrant can be subdivided into its sub-quadrants.

`1 sub 1` Sub-quadrant 1 of quadrant 1  
`1 sub 2` Sub-quadrant 2 of quadrant 1  
`1 sub 3` Sub-quadrant 3 of quadrant 1  
`1 sub 4` Sub-quadrant 4 of quadrant 1

These examples also apply to quadrants 2, 3, and 4.

### Columns

Windows can be arranged in one of four columns named `a`, `b`, `c`, and `d`.

### Thirds

The screen is divided into thirds and the window is arranged either as a column or as a row.

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

These commands resize the window while keeping its position.

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

`stack`
Stack an arbitrary count of windows.

`three columns`  
Organizes the three topmost windows into columns.
