package com.osafe.services;

import java.util.List;
import java.util.Map;

import javolution.util.FastMap;

import org.ofbiz.base.util.UtilMisc;
import org.ofbiz.base.util.UtilValidate;
import org.ofbiz.base.util.string.FlexibleStringExpander;
import org.ofbiz.service.DispatchContext;

import com.osafe.services.OsafeManageXml;

public class CustomPartyAttributeServices {

    public static final String module = CustomPartyAttributeServices.class.getName();

    public static Map<String, ?> getPartyCustomAttributeList(DispatchContext ctx, Map<String, ?> context) 
    {
    	String customPartyAttributeFilePath = FlexibleStringExpander.expandString(System.getProperty("ofbiz.home") + "/hot-deploy/osafe/import/data/xml/CustomPartyAttributes.xml", null);
    	List<Map<Object, Object>> customPartyAttributeList =  OsafeManageXml.getListMapsFromXmlFileUseCache(customPartyAttributeFilePath);
    	Map<String, Object> response = FastMap.newInstance();

    	for(Map customPartyAttributeMap : customPartyAttributeList) 
    	{
    	     if ((customPartyAttributeMap.get("SequenceNum") instanceof String) && (UtilValidate.isInteger((String)customPartyAttributeMap.get("SequenceNum")))) 
    	     {
    	    	 if(Integer.parseInt((String)customPartyAttributeMap.get("SequenceNum"))== 0)
    	    	 {
    	    		 customPartyAttributeList.remove(customPartyAttributeMap);
    	    	 }
    	         if (UtilValidate.isNotEmpty(customPartyAttributeMap.get("SequenceNum"))) 
    	         {
    	        	 customPartyAttributeMap.put("SequenceNum", Integer.parseInt((String)customPartyAttributeMap.get("SequenceNum")));
    	         } 
    	         else 
    	         {
    	        	 customPartyAttributeMap.put("SequenceNum", 0);
    	         }
    	     }
    	 }
    	customPartyAttributeList = UtilMisc.sortMaps(customPartyAttributeList, UtilMisc.toList("SequenceNum"));
    	response.put("customPartyAttributeList", customPartyAttributeList);
    	return response;
    }
    
}
