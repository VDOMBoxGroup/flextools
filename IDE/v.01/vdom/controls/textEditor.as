import flash.events.Event;

import mx.core.UITextField;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ScrollEvent;
import mx.events.ScrollEventDirection;
use namespace mx_internal;

private var codeTextField : UITextField;
private var numbersTextField : UITextField;

[Bindable]
private var _text : String;

public function get text() : String
{
	return codeEditor.text;
}

public function set text( value : String ) : void
{
	_text = value;
	undoTextFields.clearHistory();
}

private function registerEvent( flag : Boolean ) : void 
{
	if( flag )
	{
		codeEditor.addEventListener( FlexEvent.VALUE_COMMIT, codeEditor_valueCommitHandler );
		codeEditor.addEventListener( Event.CHANGE, codeEditor_changeHandler );
		codeEditor.addEventListener( ScrollEvent.SCROLL, codeEditor_scrollHandler );
	}
	else
	{
		codeEditor.removeEventListener( FlexEvent.VALUE_COMMIT, codeEditor_valueCommitHandler );
		codeEditor.removeEventListener( Event.CHANGE, codeEditor_changeHandler );
		codeEditor.removeEventListener( ScrollEvent.SCROLL, codeEditor_scrollHandler );
	}
}

private function calculateNumbers() : void 
{
	var currentLineNumber : Number = numbersTextField.numLines;
	var newLineNumber : Number = codeTextField.numLines;
	
	if( currentLineNumber == newLineNumber )
		return;
	
	var delta : Number;
	var i : Number;
	var inputString : String = "";
	
	if( newLineNumber > currentLineNumber )
	{
		delta = newLineNumber - currentLineNumber;
		for( i = 1; i <= delta; i++)
		{
			inputString += "\n" + String( currentLineNumber + i );
		}
		numbersTextField.appendText( inputString );
	}
	else
	{
		var lineOffset : int = numbersTextField.getLineOffset( newLineNumber );
		numbersTextField.replaceText( lineOffset - 1, numbersTextField.length, "" );
	}
}

private function initializeHandler( ) : void 
{
	codeTextField = codeEditor.getTextField() as UITextField;
	numbersTextField = lineNumbers.getTextField() as UITextField;
	registerEvent( true );
	calculateNumbers();
}

private function codeEditor_changeHandler( event : Event ) : void 
{
	calculateNumbers();
}

private function codeEditor_valueCommitHandler( event : FlexEvent ) : void 
{
	callLater( calculateNumbers );
}

private function codeEditor_scrollHandler( event : ScrollEvent ) : void 
{
	if( event.direction != ScrollEventDirection.VERTICAL )
		return;
	lineNumbers.verticalScrollPosition = codeEditor.verticalScrollPosition;
}