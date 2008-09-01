// ActionScript file
import mx.events.MenuEvent;
import mx.core.Application;
import flash.events.MouseEvent;


private function mainMenuHandler(mEvent:MenuEvent):void {
	
	switch (String(mEvent.item.@data)) {
		
		case "new":
			break;
		
		case "open":
			break;
		
		case "save":
			break;
		
		case "close":
			Application.application.close();
			break;
	}
}

private function colorSwitcherClickHandler(mEvt:MouseEvent):void {
	__grayColor.setStyle("borderThickness", 0);
	__redColor.setStyle("borderThickness", 0);
	__greenColor.setStyle("borderThickness", 0);
	__blueColor.setStyle("borderThickness", 0);
	
	mEvt.currentTarget.setStyle("borderThickness", 2);
}

