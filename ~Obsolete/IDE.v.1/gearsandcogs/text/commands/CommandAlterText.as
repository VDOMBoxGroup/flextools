/*
  Copyright (c) 2009 Jacob Wright
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/
package gearsandcogs.text.commands
{
	import flash.text.TextField;
	
	import flight.commands.IUndoableCommand;

	/**
	 * For handling cut/paste operations
	 */
	public class CommandAlterText implements IUndoableCommand
	{
		public function CommandAlterText(textField:TextField, oldText:String, oldSelection:Array)
		{
			this.textField = textField;
			selection = oldSelection;
			index = textField.selectionBeginIndex;
			
			if (selection[0] != selection[1]) {
				replacedText = oldText.substring(selection[0], selection[1]);
			}
			
			// if the old selectionBeginIndex is not equal to index this was a
			// paste operation.
			if (selection[0] != index) {
				text = textField.text.substring(selection[0], index);
			}
		}
		
		public var textField:TextField;
		public var replacedText:String = "";
		public var text:String = "";
		public var selection:Array;
		public var index:uint;
		
		public function execute():void
		{
			
		}

		public function undo():void
		{
			textField.replaceText(index - text.length, index, replacedText);
			textField.setSelection(selection[0], selection[1]);
		}
		
		public function redo():void
		{
			textField.replaceText(selection[0], selection[1], text);
			textField.setSelection(index, index);
		}
		
	}
}