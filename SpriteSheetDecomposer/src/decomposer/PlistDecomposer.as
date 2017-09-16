package decomposer
{
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import nodep.util.FileUtil;
	
	/**
	 * Plist资源反编器
	 * @author nodep
	 * @version 1.0
	 */	
	public class PlistDecomposer
	{
		private static var _targetFile:File;
		private static var _saveFile:File;
		
		public static function decode(file:File):void{
			_targetFile = file;
			FileUtil.choosePath(saveToFileHandler,"选择保存的目录")
			
		}
		
		private static function start(file:File,basePath:String=""):void{
			var imgDic:Dictionary = new Dictionary();
			var plistDic:Dictionary = new Dictionary();
			var sheets:Array = [];//图集
			var plists:Array = [];//图集配置文件
			var fileList:Array = file.getDirectoryListing();
			for each(var subFile:File in fileList){
				if(subFile.isDirectory){//如果是目录,则向下传递
					start(subFile,basePath+"/"+file.name);
				}else{//否则记录图集名称
					var fileName:String = FileUtil.getFileName(subFile.name);
					if(FileUtil.isImageForMac(subFile.name)){//如果是图片
						sheets.push(fileName);
						imgDic[fileName] = subFile.nativePath;
					}else if(FileUtil.isTypeFileForMac(subFile.name,"plist")){//如果是配置文件
						plists.push(fileName);
						plistDic[fileName] = subFile.nativePath;
					}
				}
			}
			if(sheets.length<=0){
				return;
			}
			//创建当前级的目录
			var dicFile:File = new File(_saveFile.nativePath+basePath+"/"+file.name);
			dicFile.createDirectory();
			//解析纹理
			while(sheets.length>0){
				var sheetName:String = sheets.pop();
				var imgUrl:String = imgDic[sheetName];
				var fileType:String = FileUtil.getFileType(imgUrl);
				if(plists.indexOf(sheetName) >= 0){//拥有这个图集的解析资源,则是图集
					var plistUrl:String = plistDic[sheetName];
					analysisSheet(imgUrl,plistUrl,dicFile.nativePath+"/"+sheetName+"_sheet");
				}else{//就是图片,直接保存
					FileUtil.copyFileTo(new File(imgUrl),dicFile.nativePath+"/"+sheetName+"."+fileType);
				}
			}
			//			var fileStream:FileStream = new FileStream();
			//			fileStream.open(dicFile,FileMode.WRITE);
		}
		
		private static function analysisSheet(imgUrl:String,plistUrl:String,savePath:String):void{
			var decoder:PlistDecomposerSub = new PlistDecomposerSub();
			decoder.imgUrl = imgUrl;
			decoder.plistUrl = plistUrl;
			decoder.savePath = savePath;
			decoder.decodeAndExport();
		}
		
		private static function saveToFileHandler(file:File):void{
			_saveFile = file;
			start(_targetFile);
		}
	}
}


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import mx.graphics.codec.PNGEncoder;

import nodep.util.FileUtil;

/**
 * 解析对象临时存储对象
 * @author nodep
 */	
class PlistDecomposerSub
{
	public var imgUrl:String;
	public var plistUrl:String;
	public var savePath:String;
	private var _loader:Loader;
	private static var _pngMaker:PNGEncoder = new PNGEncoder();
	private static const OPTS:Array = ["spriteOffset","spriteSize","spriteSourceSize","textureRect"];
	
	public function decodeAndExport():void{
		_loader = new Loader();
		_loader.loadBytes(FileUtil.getBytes(imgUrl));
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler);
	}
	
	/*
	<key>spriteOffset</key>
	<string>{0,-1}</string>
	<key>spriteSize</key>
	<string>{192,158}</string>
	<key>spriteSourceSize</key>
	<string>{320,246}</string>
	<key>textureRect</key>
	<string>{{1,1249},{192,158}}</string>
	<key>textureRotated</key>
	<false/>
	*/
	private function loadCompleteHandler(evt:Event):void{
		_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadCompleteHandler);
		var bit:Bitmap = _loader.content as Bitmap;
		var xmlStr:String = FileUtil.getStr(plistUrl);
		new File(savePath).createDirectory();//创建目录
		var xml:XML = new XML(xmlStr);
		var xmlList:XMLList = xml.dict;
		xml = xmlList[0];
		xmlList = xml.dict[0].dict;
		var keyList:XMLList = xml.dict[0].key;
		for(var i:int=0;i<keyList.length();i++){
			var imgName:String = keyList[i];
			var args:XMLList = (xmlList[i] as XML).children();
			var hasRota:Boolean = args.toString().indexOf("true/") >=0;
			var optType:String = "";
			var startP:Point;
			var sizeP:Point;
			for(var j:int=0;j<args.length();j++){
				var optIndex:int = OPTS.indexOf(args[j]+"");
				switch(optType){
					case "spriteOffset":
						break;
					case "spriteSize":
						break;
					case "spriteSourceSize":
						break;
					case "textureRect"://{{62,1},{75,113}}
						var rectStr:String = args[j]+"";
						var rects:Array = rectStr.split(",");
						var p1:int = int((rects[0] as String).substring(2));
						var p2:int = int((rects[1] as String).substr(0,(rects[1] as String).length-1));
						var p3:int = int((rects[2] as String).substring(1));
						var p4:int = int((rects[3] as String).substr(0,(rects[3] as String).length-2));
						if(hasRota){
							var t:int = p3;
							p3 = p4;
							p4 = t;
						}
						startP = new Point(p1,p2);
						sizeP = new Point(p3,p4);
						break;
				}
				if(optIndex>=0){
					optType = args[j];
				}else{
					optType = "";
				}
			}
			try{
				var btd:BitmapData = new BitmapData(sizeP.x,sizeP.y,true,0);
				var bts:ByteArray = bit.bitmapData.getPixels(new Rectangle(startP.x,startP.y,sizeP.x,sizeP.y));
				bts.position = 0;
				btd.setPixels(new Rectangle(0,0,sizeP.x,sizeP.y),bts);
				var bt:Bitmap = new Bitmap(btd);
				var targetBit:Bitmap = bt;
				if(hasRota){
					bt.rotation = -90;
					var sp:Sprite = new Sprite();
					sp.addChild(bt);
					bt.y = sizeP.x;
					targetBit = new Bitmap();
					targetBit.bitmapData = new BitmapData(sizeP.y,sizeP.x,true,0);
					targetBit.bitmapData.draw(sp);
				}
				//输出bitmapData
				var outPut:ByteArray = _pngMaker.encode(targetBit.bitmapData);
				var aa:Array = imgName.split("/");
				var u:String = savePath+"/"+aa[aa.length-1];
				if(u.indexOf(".")<0)
					u = u+".png";
				FileUtil.saveFile(outPut,u);
			}catch(e:Error){
				trace("产生了异常情况");	
			}
		}
	}
}