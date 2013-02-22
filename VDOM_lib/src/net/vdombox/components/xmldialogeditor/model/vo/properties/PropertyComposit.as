package net.vdombox.components.xmldialogeditor.model.vo.properties
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.OptionGroupVO;
	import net.vdombox.components.xmldialogeditor.model.vo.OptionVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBaseVO;

	public class PropertyComposit extends AttributeBaseVO
	{
		private var _value : ArrayCollection;
		private var _type : uint;
		
		public function PropertyComposit(name:String, value : XML, type : uint = 0 )
		{
			super(name);
			
			this.type = type;
			this.value = new ArrayCollection();
			
			var option : XML;
			
			if ( type == 0 )
			{
				if ( !value )
				{
					this.value.addItem( new OptionVO() );
					this.value.addItem( new OptionVO() );
				}
				else
				{
					for each ( option in value.children() )
					{
						this.value.addItem( new OptionVO( option ) );
					}
				}
			}
			else
			{
				if ( !value )
				{
					this.value.addItem( new OptionGroupVO() );
					this.value.addItem( new OptionGroupVO() );
				}
				else
				{
					for each ( option in value.children() )
					{
						this.value.addItem( new OptionGroupVO( option ) );
					}
				}
			}
			
		}
		
		[Bindable]
		public function get value():ArrayCollection
		{
			return _value;
		}
		
		public function set value(value:ArrayCollection):void
		{
			_value = value;
		}
		
		public function toXML() : XML
		{
			var xml : XML = <Property name="options"></Property>;
			
			for each ( var optionVO : * in value )
			{
				xml.appendChild( optionVO.toXML() );
			}
			
			return xml;
		}

		public function get type():uint
		{
			return _type;
		}

		public function set type(value:uint):void
		{
			_type = value;
		}

	}
}