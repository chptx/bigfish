package com.osafe.events;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;  
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javolution.util.FastMap;
import org.ofbiz.base.util.Debug;
import org.ofbiz.base.util.UtilHttp;
import org.ofbiz.base.util.UtilProperties;
import org.ofbiz.base.util.UtilValidate;
import org.ofbiz.entity.Delegator;
import org.ofbiz.entity.GenericValue;
import org.ofbiz.entity.util.EntityUtil;
import org.ofbiz.order.shoppingcart.CartItemModifyException;
import org.ofbiz.order.shoppingcart.CheckOutHelper;
import org.ofbiz.order.shoppingcart.ItemNotFoundException;
import org.ofbiz.order.shoppingcart.ShoppingCart;
import org.ofbiz.order.shoppingcart.ShoppingCart.CartPaymentInfo;
import org.ofbiz.order.shoppingcart.ShoppingCartItem;
import org.ofbiz.product.config.ProductConfigWrapper;
import org.ofbiz.service.LocalDispatcher;
import org.ofbiz.service.ServiceUtil;
import org.ofbiz.order.shoppingcart.ShoppingCartHelper;
import org.apache.commons.lang.StringUtils;

public class OsafeAdminCheckoutEvents {

	public static String setGiftMessage(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map<String, Object> context = FastMap.newInstance(); 
    	Map<String, Object> params = UtilHttp.getParameterMap(request);
        String cartLineIndexStr = (String) params.get("cartLineIndex");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        
        int cartLineIndex = -1;
        if (UtilValidate.isNotEmpty(cartLineIndexStr)) 
        {
            try 
            {
            	cartLineIndex = Integer.parseInt(cartLineIndexStr);
            } 
            catch (NumberFormatException nfe) 
            {
                return "error";
            }
        }
        
        if(UtilValidate.isNotEmpty(sc) && UtilValidate.isNotEmpty(cartLineIndex) && cartLineIndex>-1)
        {
        	ShoppingCartItem sci = sc.findCartItem(cartLineIndex);
        	if(UtilValidate.isNotEmpty(sci)) 
            {
        		for(Entry<String, Object> entry : params.entrySet()) 
                {
        			String attrName = entry.getKey();
        			int underscorePos = attrName.lastIndexOf('_');
            		if (underscorePos >= 0) 
            		{
            			try 
            			{
            				//If we have more than one product, index will tell us which one we are referencing [GIFT_MSG_FROM_{index}, GIFT_MSG_TO_{index}, GIFT_MSG_TEXT_{index}]
            				String indexStr = attrName.substring(underscorePos + 1);
            				int index;
                            try 
                            {
                            	index = Integer.parseInt(indexStr);
                            } 
                            catch (NumberFormatException nfe) 
                            {
                                return "error";
                            }
                            
                            //prefix with "0" if index is less than 10
                            if(UtilValidate.isNotEmpty(index) && index < 10)
                            {
                            	indexStr = String.format("%02d", index);
                            }
                            
                            //from
                            if (attrName.startsWith("from_"))
                        	{
                            	String trimValue = StringUtils.trimToEmpty((String) entry.getValue());
                            	if(UtilValidate.isNotEmpty(trimValue))
                            	{
                            		sci.setOrderItemAttribute("GIFT_MSG_FROM_" + indexStr , (String) entry.getValue());
                            	}
                            	else
                            	{
                            		//remove this attribute if it is empty
                            		if(null != sci.getOrderItemAttribute("GIFT_MSG_FROM_" + indexStr))
                            		{
                            			sci.removeOrderItemAttribute("GIFT_MSG_FROM_" + indexStr);
                            		}
                            	}
                        	}
                			
                			//to
                            if (attrName.startsWith("to_"))
                        	{
                            	String trimValue = StringUtils.trimToEmpty((String) entry.getValue());
                            	if(UtilValidate.isNotEmpty(trimValue))
                            	{
                            		sci.setOrderItemAttribute("GIFT_MSG_TO_" + indexStr , (String) entry.getValue());
                            	}
                            	else
                            	{
                            		//remove this attribute if it is empty
                            		if(null != sci.getOrderItemAttribute("GIFT_MSG_TO_" + indexStr))
                            		{
                            			sci.removeOrderItemAttribute("GIFT_MSG_TO_" + indexStr);
                            		}
                            	}
                        	}
                			
                          //text
                            if (attrName.startsWith("giftMessageText_"))
                        	{
                            	String trimValue = StringUtils.trimToEmpty((String) entry.getValue());
                            	String trimEnumValue = StringUtils.trimToEmpty((String) params.get("giftMessageEnum_" + indexStr));
                            	if(UtilValidate.isNotEmpty(trimValue))
                            	{
                            		sci.setOrderItemAttribute("GIFT_MSG_TEXT_" + indexStr , (String) entry.getValue());
                            	}
                            	else if(UtilValidate.isEmpty(trimEnumValue) && null != sci.getOrderItemAttribute("GIFT_MSG_TEXT_" + indexStr))
                            	{
                            		sci.removeOrderItemAttribute("GIFT_MSG_TEXT_" + indexStr);
                            	}
                        	}
                            else if(attrName.startsWith("giftMessageEnum_") && UtilValidate.isNotEmpty(StringUtils.trimToEmpty((String) entry.getValue())) && UtilValidate.isEmpty(params.get("giftMessageText_" + index)))
                            {
                            	sci.setOrderItemAttribute("GIFT_MSG_TEXT_" + indexStr , (String) entry.getValue());
                            }
            			}
            			catch (NumberFormatException nfe) 
            			{
            				return "error";
                        } 
            			catch (Exception e) 
            			{
            				return "error";
                        }
            		}
                }
            }
        }
        
        return "success";
    }
    
}
