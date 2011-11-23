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
		{ name: 'basicstyles',	items : [ 'Bold','Italic','Underline','Strike','Subscript','Superscript' ] },
		{ name: 'paragraph',	items : [ 'NumberedList','BulletedList','-','Outdent','Indent','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
		{ name: 'links',		items : [ ] },
		'/',
		{ name: 'insert',		items : [ 'Image','PasteImage','Table','HorizontalRule' ] },
		{ name: 'styles',		items : [ 'Format','Styles','RemoveFormat' ,'Font','FontSize' ] },
		{ name: 'colors',		items : [ 'TextColor','BGColor' ] },
		{ name: 'tools',		items : [ /*'Maximize'*/ ] },
		{ name: 'document',		items : [ 'Source' ] }
	];
	
};

CKEDITOR.stylesSet.add('vdomclasses', [
  { name: 'Button', element: 'span', attributes: { 'class': 'button' } },
  { name: 'Image title', element: 'span', attributes: { 'class': 'img_title' } },
  
  { name: 'Syntax: Python', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: python' } }, 
  { name: 'Syntax: AS3', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: as3' } }, 
  { name: 'Syntax: C++', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: cpp' } }, 
  { name: 'Syntax: C#', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: csharp' } }, 
  { name: 'Syntax: CSS', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: css' } }, 
  { name: 'Syntax: Delphi', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: delphi' } }, 
  { name: 'Syntax: Java', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: java' } }, 
  { name: 'Syntax: JS', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: js' } }, 
  { name: 'Syntax: Perl', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: perl' } }, 
  { name: 'Syntax: Php', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: php' } }, 
  { name: 'Syntax: Sql', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: sql' } }, 
  { name: 'Syntax: Vb', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: vb' } }, 
  { name: 'Syntax: XML', element: 'pre', attributes: { 'name': 'code', 'class': 'brush: xml' } }, 
  ]);
