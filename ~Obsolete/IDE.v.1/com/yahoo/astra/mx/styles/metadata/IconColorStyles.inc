/*
Copyright (c) 2008 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/

/**
 *  The color for the icon in a skin. 
 *  For example, this style is used by the CheckBoxIcon skin class 
 *  to draw the check mark for a CheckBox control, 
 *  by the ComboBoxSkin class to draw the down arrow of the ComboBox control, 
 *  and by the DateChooserMonthArrowSkin skin class to draw the month arrow 
 *  for the DateChooser control. 
 * 
 *  The default value depends on the component class;
 *  if it is not overridden by the class, the default value is <code>0x111111</code>.
 */
[Style(name="iconColor", type="uint", format="Color", inherit="yes")]

/**
 *  The color for the icon in a disabled skin. 
 *  For example, this style is used by the CheckBoxIcon skin class 
 *  to draw the check mark for a disabled CheckBox control, 
 *  by the ComboBoxSkin class to draw the down arrow of a disabled ComboBox control, 
 *  and by the DateChooserMonthArrowSkin skin class to draw the month arrow 
 *  for a disabled DateChooser control. 
 * 
 *  The default value depends on the component class;
 *  if it is not overridden by the class, the default value is <code>0x999999</code>.
 */
[Style(name="disabledIconColor", type="uint", format="Color", inherit="yes")]