import flash.events.Event;

import vdom.managers.AuthenticationManager;

[Bindable]
private var authenticationManager : AuthenticationManager = AuthenticationManager.getInstance();

[Embed( source="/assets/main/vdom_logo.png" )]
[Bindable]
private var vdomLogo : Class;

private function showMainHandler() : void
{
	var dummy : * = ""; // FIXME remove dummy
}

private function logoutHandler() : void
{

}
private function aaa( event : Event ) : void
{
	contentStack.selectedIndex = 1;
}