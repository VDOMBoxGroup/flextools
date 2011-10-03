/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	//config.width = "810";
	//config.pasteFromWordRemoveFontStyles = false;
	
	config.stylesSet = 'vdomclasses';
	
	config.toolbar =
	[
		{ name: 'clipboard',	items : [ 'Undo','Redo' ] },
		{ name: 'editing',		items : [ 'Find','Replace','-','SelectAll' ] },
		{ name: 'forms',		items : [ ] },
		{ name: 'basicstyles',	items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
		{ name: 'paragraph',	items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
		{ name: 'links',		items : [ ] },
		'/',
		{ name: 'insert',		items : [ 'Image','Table','HorizontalRule' ] },
		{ name: 'styles',		items : [ 'Format','Styles','Font','FontSize' ] },
		{ name: 'colors',		items : [ 'TextColor','BGColor' ] },
		{ name: 'tools',		items : [ /*'Maximize'*/ ] },
		{ name: 'document',		items : [ 'Source' ] }
	];
	
};

CKEDITOR.stylesSet.add('vdomclasses', [
  { name: 'Button', element: 'span', attributes: { 'class': 'button' } },
  { name: 'Image title', element: 'span', attributes: { 'class': 'img_title' } } ]);