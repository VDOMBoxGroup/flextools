package net.vdombox.ide.modules.wysiwyg.view.components
{
	import mx.containers.accordionClasses.AccordionHeader;
	import mx.controls.Button;

	import net.vdombox.ide.modules.wysiwyg.view.skins.AccordionHeaderSkin;

	public class TypesAccordionHeader extends AccordionHeader
	{
		
		
		
		override public function set selected( value : Boolean ) : void
		{
			super.selected = value;
			
			setStyle( "color", "white");
		}
		
	}
}