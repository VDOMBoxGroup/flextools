package net.vdombox.ide.modules.wysiwyg.model.business
{
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.AttributeBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ColorPicker;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ComboBoxAttribute;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ComboBoxObjectAttribute;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.Multiline;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.TextInputAttribute;
	import net.vdombox.ide.modules.wysiwyg.view.components.externalEditor.ExternalEditor;

	public class AttributeItemRendererManager
	{
		private static var instance : AttributeItemRendererManager;
		private var _multilineIndex : int = 0;
		private var multilineVector : Vector.<Multiline> = new Vector.<Multiline>();
		private var _colorPickerIndex : int = 0;
		private var colorPickerVector : Vector.<ColorPicker> = new Vector.<ColorPicker>();;
		private var _comboBoxIndex : int = 0;
		private var comboBoxVector : Vector.<ComboBoxAttribute> = new Vector.<ComboBoxAttribute>();
		private var _comboBoxObjectIndex : int = 0;
		private var comboBoxObjectVector : Vector.<ComboBoxObjectAttribute> = new Vector.<ComboBoxObjectAttribute>();
		private var _externalEditorIndex : int = 0;
		private var externalEditorVector : Vector.<ExternalEditor> = new Vector.<ExternalEditor>();
		private var _resourceSelectorIndex : int = 0;
		private var resourceSelectorVector : Vector.<ResourceSelector> = new Vector.<ResourceSelector>();
		private var _textInputIndex : int = 0;
		private var textInputVector : Vector.<TextInputAttribute> = new Vector.<TextInputAttribute>();

		public function AttributeItemRendererManager()
		{
			if ( instance )
				throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
		}
		
		public function get comboBoxIndex():int
		{
			return _comboBoxIndex;
		}

		public function get comboBoxObjectIndex():int
		{
			return _comboBoxObjectIndex;
		}

		public function get externalEditorIndex():int
		{
			return _externalEditorIndex;
		}

		public function get resourceSelectorIndex():int
		{
			return _resourceSelectorIndex;
		}

		public function get textInputIndex():int
		{
			return _textInputIndex;
		}

		public function get colorPickerIndex():int
		{
			return _colorPickerIndex;
		}

		public function get multilineIndex():int
		{
			return _multilineIndex;
		}

		public static function getInstance() : AttributeItemRendererManager
		{
			if ( !instance )
				instance = new AttributeItemRendererManager();
			
			return instance;
		}
		
		public function getMultiline( index : int) : Multiline
		{
			if ( index != -1 && index < _multilineIndex )
				return multilineVector[ index ];
			
			var multiline : Multiline;
			
			if ( _multilineIndex >= multilineVector.length )
			{
				multiline = new Multiline();
				multilineVector.push( multiline );
			}
			else
			{
				multiline = multilineVector[ _multilineIndex ];
			}
			
			_multilineIndex++;
			return multiline;
		}
		
		public function getColorPicker( index : int ) : ColorPicker
		{
			if ( index != -1 && index < _colorPickerIndex )
				return colorPickerVector[ index ];
			
			var colorPicker : ColorPicker;
			
			if ( _colorPickerIndex >= colorPickerVector.length )
			{
				colorPicker = new ColorPicker();
				colorPickerVector.push( colorPicker );
			}
			else
			{
				colorPicker = colorPickerVector[ _colorPickerIndex ];
			}
			
			_colorPickerIndex++;
			return colorPicker;
		}
		
		public function getComboBox( index : int ) : ComboBoxAttribute
		{
			if ( index != -1 && index < _comboBoxIndex )
				return comboBoxVector[ index ];
			
			var comboBox : ComboBoxAttribute;
			
			if ( _comboBoxIndex >= comboBoxVector.length )
			{
				comboBox = new ComboBoxAttribute();
				comboBoxVector.push( comboBox );
			}
			else
			{
				comboBox = comboBoxVector[ _comboBoxIndex ];
			}
			
			_comboBoxIndex++;
			return comboBox;
		}
		
		public function getComboBoxObject( index : int ) : ComboBoxObjectAttribute
		{
			if ( index != -1 && index < _comboBoxObjectIndex )
				return comboBoxObjectVector[ index ];
			
			var comboBoxObject : ComboBoxObjectAttribute;
			
			if ( _comboBoxObjectIndex >= comboBoxObjectVector.length )
			{
				comboBoxObject = new ComboBoxObjectAttribute();
				comboBoxObjectVector.push( comboBoxObject );
			}
			else
			{
				comboBoxObject = comboBoxObjectVector[ _comboBoxObjectIndex ];
			}
			
			_comboBoxObjectIndex++;
			return comboBoxObject;
		}
	
		public function getExternalEditor( index : int ) : ExternalEditor
		{
			if ( index != -1 && index < _externalEditorIndex )
				return externalEditorVector[ index ];
			
			var externalEditor : ExternalEditor;
			
			if ( _externalEditorIndex >= externalEditorVector.length )
			{
				externalEditor = new ExternalEditor();
				externalEditorVector.push( externalEditor );
			}
			else
			{
				externalEditor = externalEditorVector[ _externalEditorIndex ];
			}
			
			_externalEditorIndex++;
			return externalEditor;
		}
		
		public function getResourceSelector( index : int ) : ResourceSelector
		{
			if ( index != -1 && index < _resourceSelectorIndex )
				return resourceSelectorVector[ index ];
			
			var resourceSelector : ResourceSelector;
			
			if ( _resourceSelectorIndex >= resourceSelectorVector.length )
			{
				resourceSelector = new ResourceSelector();
				resourceSelectorVector.push( resourceSelector );
			}
			else
			{
				resourceSelector = resourceSelectorVector[ _resourceSelectorIndex ];
			}
			
			_resourceSelectorIndex++;
			return resourceSelector;
		}
		
		public function getTextInput( index : int ) : TextInputAttribute
		{
			if ( index != -1 && index < _textInputIndex )
				return textInputVector[ index ];
			
			var textInput : TextInputAttribute;
			
			if ( _textInputIndex >= textInputVector.length )
			{
				textInput = new TextInputAttribute();
				textInputVector.push( textInput );
			}
			else
			{
				textInput = textInputVector[ _textInputIndex ];
			}
			
			_textInputIndex++;
			return textInput;
		}
		
		
		public function resetIndexes() : void
		{
			_multilineIndex = 0;
			_colorPickerIndex = 0;
			_comboBoxIndex = 0;
			_comboBoxObjectIndex = 0;
			_externalEditorIndex = 0;
			_resourceSelectorIndex = 0;
			_textInputIndex = 0;
		}
		
	}
}