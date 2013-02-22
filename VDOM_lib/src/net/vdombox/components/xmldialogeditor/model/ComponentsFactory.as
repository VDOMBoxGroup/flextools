package net.vdombox.components.xmldialogeditor.model
{
	import net.vdombox.components.xmldialogeditor.model.vo.components.ButtonVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.CheckBoxGroupVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.CheckBoxVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.ContainerVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.DropDownVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.HypertextVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.ItemVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.LabelVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.ListBoxVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.PasswordVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.RadioButtonGroupVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.RadioButtonVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.TextAreaVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.TextBoxVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.UploadVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentBase;

	public class ComponentsFactory
	{
		public function ComponentsFactory()
		{
		}
		
		public static function getComponentByXML( xml : XML ) : ComponentBase
		{
			var nameComponent : String = xml.localName();
			
			return getComponent( nameComponent, xml );		
		}
		
		public static function getComponentByName( nameComponent : String ) : ComponentBase
		{			
			return getComponent( nameComponent );		
		}
		
		private static function getComponent( nameComponent : String, xml : XML = null ) : ComponentBase
		{
			switch(nameComponent)
			{
				case "Container":
				{
					return new ContainerVO( xml );
					
					break;
				}
					
				case "Item":
				{
					return new ItemVO( xml );
					
					break;
				}	
					
				case "Label":
				{
					return new LabelVO( xml );
					
					break;
				}
					
				case "TextBox":
				{
					return new TextBoxVO( xml );
					
					break;
				}
					
				case "Password":
				{
					return new PasswordVO( xml );
					
					break;
				}
					
				case "TextArea":
				{
					return new TextAreaVO( xml );
					
					break;
				}
					
				case "DropDown":
				{
					return new DropDownVO( xml );
					
					break;
				}
					
				case "ListBox":
				{
					return new ListBoxVO( xml );
					
					break;
				}
					
				case "RadioButton":
				{
					return new RadioButtonVO( xml );
					
					break;
				}
					
				case "RadioButtonGroup":
				{
					return new RadioButtonGroupVO( xml );
					
					break;
				}
					
				case "CheckBox":
				{
					return new CheckBoxVO( xml );
					
					break;
				}
					
				case "CheckBoxGroup":
				{
					return new CheckBoxGroupVO( xml );
					
					break;
				}
					
				case "Button":
				{
					return new ButtonVO( xml );
					
					break;
				}
					
				case "Upload":
				{
					return new UploadVO( xml );
					
					break;
				}
					
				case "Hypertext":
				{
					return new HypertextVO( xml );
					
					break;
				}
					
					
					
				default:
				{
					break;
				}
			}
			
			return null;
		}
	}
}