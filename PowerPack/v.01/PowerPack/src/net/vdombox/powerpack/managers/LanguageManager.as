package net.vdombox.powerpack.managers
{
import ExtendedAPI.com.utils.Utils;

import net.vdombox.powerpack.dialog.ModalDialog;

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.controls.Alert;
import mx.utils.ObjectProxy;
import mx.utils.StringUtil;

public class LanguageManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  @private
	 */
	private static var _instance:LanguageManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance():LanguageManager
	{
		if (!_instance)
		{
			_instance = new LanguageManager();
		
			var defaultCaptions:Object = {
				// button titles
				ok:"OK",
				yes:"Yes",
				no:"No",					
				cancel:"Cancel",
				confirm:"Confirm",
				submit:"Submit",
				exit:"Exit",
				browse:"Browse",
				accept:"Accept",
				run:"Run",
				remove:"Remove",
				del:"Delete",
				finish:"Finish",
				next: "Next",
				back: "Back",
				open: "Open",
				load: "Load",
				
				// titles
				graph_editor: "Graph Editor",
				confirmation:"Confirmation",					
				error:"Error",
				warning:"Warning",
				info:"Information",
				result:"Result",
				unnamed:"Unnamed",				

				all:"All",
				none:"none",
				noname:"noname",
				other:"other",
				
				language:"Language",
				connection:"Connection",
				authentication: "Authentication",
				parameters:"Parameters",
				properties:"Properties",
				preferences:"Preferences",
				template:"Template",
				file:"File",
				folder:"Folder",
				help:"Help",
				host:"Host",
				port:"Port",
				login:"Login",
				password:"Password",
				
				// menu items
				menu_file:"_File",
				menu_new_template:"_New Template",
				menu_new_tab:"New _Tab",
				menu_new_category:"New Ca_tegory",
				menu_open_file:"_Open File...",
				menu_close:"_Close",
				menu_save:"_Save",
				menu_save_as:"Save _As...",
				menu_exit:"E_xit",
				
				menu_import:"Import",
				menu_import_from_app:"From VDOM application...",
				menu_import_from_tpl:"From template...",
				menu_template:"_Template",
				menu_validate:"_Validate",
				menu_properties:"_Properties",
				menu_preferences:"_Preferences",
				
				menu_settings:"_Settings",
				menu_language:"_Language",
				menu_connection:"_Connection",
				menu_parameters:"_Parameters",
				menu_help:"_Help",
				
				open_file:"Open file",
				save_file:"Save file",
				select_file:"Select file",
				select_folder:"Select folder",

				select_all: "Select all",
				select_none: "Select none",
				
				// common messages
				msg_file_not_exists: "File doesn't exist.",
				msg_cannot_save_file: "Cannot save to this location.",
				msg_ioerror_occurs: "IOError exception occurs.",
				msg_cannot_open_tpl: "Cannot open template.",
				msg_not_valid_tpl_file: "Not valid template file.",
				msg_enter_valid_graph_name: "Enter a valid graph name.",
				msg_enter_unique_graph_name: "Enter unique graph name.",
				msg_enter_unique_category_label: "Enter unique category label.",
				msg_cannot_remove_nonempty_cat: "You cannot remove non empty category."
			};
			
			LanguageManager.setSentences(defaultCaptions);
			
		   	LanguageManager.bindSentence('ok', Alert, "okLabel");
		   	LanguageManager.bindSentence('yes', Alert, "yesLabel");
		   	LanguageManager.bindSentence('no', Alert, "noLabel");
		   	LanguageManager.bindSentence('cancel', Alert, "cancelLabel");
	
			LanguageManager.bindSentence('ok', ModalDialog, "okLabel");
			LanguageManager.bindSentence('yes', ModalDialog, "yesLabel");
			LanguageManager.bindSentence('no', ModalDialog, "noLabel");
			LanguageManager.bindSentence('cancel', ModalDialog, "cancelLabel");	    
		}

		return _instance;
	}
	
	/**
	 *  @private
	 */
	public static function get instance():LanguageManager
	{
		return getInstance();
	}	

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function LanguageManager()
	{
		super();

		if (_instance)
			throw new Error("Instance already exists.");
		
		BindingUtils.bindSetter(languageChangeHandler, this, '_languageXML');
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------	

    private var _defaultSentences:Object = {};
    
    private var _bindStack:Dictionary = new Dictionary(true);
	    	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------			

    //----------------------------------
	//  languageXML
    //----------------------------------	

	[Bindable]
	public var _languageXML:XML;
    
    public static function get languageXML():XML
    {
    	return instance._languageXML;
    }	
    
    public static function set languageXML(value:XML):void
    {
    	instance._languageXML = value;
    }	
	
    //----------------------------------
	//  sentence
    //----------------------------------	

    private var _sentences:ObjectProxy = new ObjectProxy({});
    
    public static function get sentences():ObjectProxy
    {
    	return instance._sentences;
    }
    
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	private static function isValidLabel(label:String):Boolean
	{
		if(!label)
			return false;
		
		if(/^[a-z]\w*$/i.test(label)==false)
			return false;				
		
		if(label=='type' || label=='object' || label=='uid')
			return false;
			
		return true;
	}
	
	public static function bindSentence(label:String, site:Object, prop:String="label"):void
	{
		if(!isValidLabel(label))
			return;
			
		if(!instance._sentences.hasOwnProperty(label))
			instance._sentences[label] = "";
		
		if(!site.hasOwnProperty(prop))
			return;
		
		if(instance._bindStack[site])
		{
			if(instance._bindStack[site].hasOwnProperty(prop))
				instance._bindStack[site][prop].unwatch();	
		}
		else
		{
			instance._bindStack[site] = new Object();
		}
		
		var watcher:ChangeWatcher = BindingUtils.bindProperty(site, prop, instance._sentences, label);
		
		instance._bindStack[site][prop] = watcher;
	}
	
    public static function setSentences(value:Object):void
    {
    	if(!value)
    		return;
    	
		for(var p:String in value)
		{
			if(!(value[p] is String) || !isValidLabel(p))
				continue;
				
			var str:String = value[p].toString();
			
			if(!str)
				continue;
			
			// if used default value and get new one then update current value  
			if(instance._defaultSentences[p] && 
				instance._sentences[p]==instance._defaultSentences[p] && 
				instance._defaultSentences[p]!=str)
			{
				instance._sentences[p] = str;
			}

			instance._defaultSentences[p] = str;
			
			if(!instance._sentences[p])
				instance._sentences[p] = str;
		}
    }

    private function languageChangeHandler(xml:XML):void
    {
		for (var elm:String in _defaultSentences)
		{
			if(xml)
				_sentences[elm] = Utils.getStringOrDefault(xml..sentense.(@label==elm), _defaultSentences[elm]);
			else
				_sentences[elm] = _defaultSentences[elm];
		} 

		if(!xml)
			return;
			
		for each (var item:XML in xml..sentense.(hasOwnProperty('@label') && @label.toString()))
		{
			 if(!isValidLabel(item.@label.toString()))
			 	continue;
			 	
			_sentences[item.@label] = item.toString();
		} 
    }
    
    public static function getSentences(template:String):String
    {
    	var arr:Array = [];
    	var res:String = '';
    	
    	for (var elm:String in instance._sentences)
    	{
    		arr.push(StringUtil.substitute(template, elm, instance._sentences[elm]));	
    	}
    	
    	arr.sort();
    	res = arr.join('');
    	
    	return res;
    }		
}
}