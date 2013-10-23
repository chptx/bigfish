package common;

import javolution.util.FastList;
import javolution.util.FastMap;

import org.apache.tools.ant.types.FileList;
import org.ofbiz.base.util.*
import org.ofbiz.base.util.string.*;

import java.util.List;
import java.util.Map;

import org.ofbiz.base.util.FileUtil;
import com.osafe.util.Util;

letestVersionFile = null;
varsionFileList = FastList.newInstance();

osafeProperties = UtilProperties.getResourceBundleMap("OsafeProperties.xml", locale);
versionFilePath = FlexibleStringExpander.expandString(osafeProperties.bigfishVersionFilesPath, context);
fileList = FileUtil.findFiles("txt", versionFilePath, null, null);

if(UtilValidate.isNotEmpty(fileList))
{
      for (varsionFile in fileList)
      {
          if (varsionFile.getName().startsWith("BF-Version-Upgrade-V"))
          {
              infoMap = FastMap.newInstance();
              infoMap.put("file", varsionFile);
              infoMap.put("fileName", varsionFile.getName());
              infoMap.put("fileNameUpperCase", varsionFile.getName().toUpperCase());
              String fileData = FileUtil.readTextFile(varsionFile, true).toString();
              infoMap.put("fileData", Util.getFormattedText(StringUtil.htmlEncoder.encode(System.getProperty("line.separator").concat(fileData))));
              varsionFileList.add(infoMap);
          }
      }
}
if(UtilValidate.isNotEmpty(varsionFileList))
{
    varsionFileList = UtilMisc.sortMaps(varsionFileList, ["fileNameUpperCase"]);
    letestVersionFile = varsionFileList.last();
}
context.letestVersionFile = letestVersionFile;
context.varsionFileList = varsionFileList;

