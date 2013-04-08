/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

/**
 * @file Paste as plain text plugin
 */

(function()
{
	// The pastetext command definition.
	var pasteTemplateCmd =
	{
		exec : function( editor )
		{
			pasteTemplate();
			return true;
		}
	};

	// Register the plugin.
	CKEDITOR.plugins.add( 'pasteTemplate',
	{
		init : function( editor )
		{
			var commandName = 'pasteTemplate',
				command = editor.addCommand( commandName, pasteTemplateCmd );

			editor.ui.addButton( 'PasteTemplate',
				{
					label : "Paste template",
					command : commandName,
					icon : this.path + 'images/imagePasteTemplate.png'
				});
		},

		requires : [ 'clipboard' ]
	});

})();


/**
 * Whether to force all pasting operations to insert on plain text into the
 * editor, loosing any formatting information possibly available in the source
 * text.
 * <strong>Note:</strong> paste from word is not affected by this configuration.
 * @name CKEDITOR.config.forcePasteAsPlainText
 * @type Boolean
 * @default false
 * @example
 * config.forcePasteAsPlainText = true;
 */
