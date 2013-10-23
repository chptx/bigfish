/*******************************************************************************
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *******************************************************************************/
package com.osafe.events;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import javolution.util.FastList;
import javolution.util.FastMap;

import org.ofbiz.base.util.Debug;
import org.ofbiz.base.util.UtilDateTime;
import org.ofbiz.base.util.UtilMisc;
import org.ofbiz.base.util.UtilProperties;
import org.ofbiz.base.util.UtilValidate;
import org.ofbiz.entity.Delegator;
import org.ofbiz.entity.GenericEntityException;
import org.ofbiz.entity.GenericValue;
import org.ofbiz.entity.transaction.TransactionUtil;
import org.ofbiz.entity.util.EntityUtil;
import org.ofbiz.order.order.OrderReadHelper;
import org.ofbiz.order.shoppingcart.ShoppingCart;
import org.ofbiz.order.shoppingcart.ShoppingCartItem;
import org.ofbiz.product.product.ProductWorker;
import org.ofbiz.service.GenericServiceException;
import org.ofbiz.service.LocalDispatcher;
import org.ofbiz.service.ServiceUtil;

import com.osafe.util.Util;

/**
 * Events used for processing checkout and orders.
 */
public class CheckOutEvents {

    public static final String module = CheckOutEvents.class.getName();
    private static final ResourceBundle PARAMETERS_RECURRENCE = UtilProperties.getResourceBundle("Parameters_Recurrence.xml", Locale.getDefault());

    public static String autoCaptureAuthPayments(HttpServletRequest request, HttpServletResponse response) {
        // warning there can only be ONE payment preference for this to work
        // you cannot accept multiple payment type when using an external gateway
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        GenericValue userLogin = (GenericValue) request.getSession().getAttribute("userLogin");
        String result = "success";

        //LS: Note: This service is automatically called from controller_ecommerce (autoCpaturePayments) checkout flow.
        //If a client wants to only 'approve' orders and not capture when order is placed update parameter CHECKOUT_CC_CAPTURE_FLAG=FALSE.
        String autoCapture =Util.getProductStoreParm(request, "CHECKOUT_CC_CAPTURE_FLAG");
        if (UtilValidate.isNotEmpty(autoCapture) && "FALSE".equals(autoCapture.toUpperCase()))
        {
            return result;

        }

        
        String orderId = (String) request.getAttribute("orderId");
        try {
            /*
             * A bit of a hack here to get the admin user since to capture payments and complete the order requires a user who has
             * the proper security permissions
             */
            GenericValue sysLogin = delegator.findByPrimaryKeyCache("UserLogin", UtilMisc.toMap("userLoginId", "admin"));
            List lOrderPaymentPreference = delegator.findByAnd("OrderPaymentPreference", UtilMisc.toMap("orderId", orderId, "statusId", "PAYMENT_AUTHORIZED"));
            if (UtilValidate.isNotEmpty(lOrderPaymentPreference)) {
                /*
                 * This will complete the order generate invoice and capture any payments.
                 * OrderChangeHelper.completeOrder(dispatcher, sysLogin, orderId);
                 */

                /*
                 * To only capture payments and leave the order in approved status. Remove the complete order call,
                 */
                GenericValue gvOrderPayment = EntityUtil.getFirst(lOrderPaymentPreference);
                Map<String, Object> serviceContext = UtilMisc.toMap("userLogin", sysLogin, "orderId", orderId, "captureAmount", gvOrderPayment.getBigDecimal("maxAmount"));
                Map callResult = dispatcher.runSync("captureOrderPayments", serviceContext);
                ServiceUtil.getMessages(request, callResult, null);
            }
        } catch (Exception e) {
            Debug.logError(e, module);
        }

        return result;
    }
    
    public static String processCartRecurrence(HttpServletRequest request, HttpServletResponse response) {
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        GenericValue userLogin = (GenericValue) request.getSession().getAttribute("userLogin");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        try 
        {
        	if (UtilValidate.isEmpty(userLogin))
        	{
        		userLogin = delegator.findByPrimaryKeyCache("UserLogin", UtilMisc.toMap("userLoginId", "admin"));
        		
        	}
        	for (Iterator<?> item = sc.iterator(); item.hasNext();) 
        	{
            	ShoppingCartItem sci = (ShoppingCartItem)item.next();
            	if ("SLT_AUTO_REODR".equals(sci.getShoppingListId())) 
            	{
                    Map serviceCtx = UtilMisc.toMap("userLogin", userLogin);
                    serviceCtx.put("partyId", sc.getOrderPartyId());
                    serviceCtx.put("productStoreId", sc.getProductStoreId());
                    serviceCtx.put("listName", "Shopping List Created From Shopping Cart for Product Id:" + sci.getProductId());
                    serviceCtx.put("shoppingListTypeId", "SLT_AUTO_REODR");
                    Map newListResult = null;
                    try 
                    {
                        newListResult = dispatcher.runSync("createShoppingList", serviceCtx);
                    } 
                    catch (GenericServiceException e) 
                    {
                        Debug.logError(e, "Problems creating new ShoppingList", module);
                    }

                    // check for errors
                    if (ServiceUtil.isError(newListResult)) 
                    {
                        Debug.logError("Problems creating new ShoppingList", module);
                    }

                    // get the new list id
                    if (UtilValidate.isNotEmpty(newListResult)) 
                    {
                    	sci.setShoppingList((String) newListResult.get("shoppingListId"), sci.getShoppingListItemSeqId());
                    }
            	}
        	}
        	
        } 
        catch (Exception e)
        {
            Debug.logError(e, "Problems creating new ShoppingList From Shopping Cart", module);
        	  
        }
        
        String result = "success";
        
        return result;
        
    }
    
    public static String processCartRecurrenceItems(HttpServletRequest request, HttpServletResponse response) {
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        GenericValue userLogin = (GenericValue) request.getSession().getAttribute("userLogin");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        String orderId = sc.getOrderId();
        
        try 
        {
        	if (UtilValidate.isNotEmpty(orderId))
        	{
                GenericValue orderHeader = null;
                orderHeader = delegator.findByPrimaryKey("OrderHeader", UtilMisc.toMap("orderId", orderId));
                OrderReadHelper orh = new OrderReadHelper(orderHeader);
                GenericValue paymentPref = EntityUtil.getFirst(orh.getPaymentPreferences());
                GenericValue shipGroup = EntityUtil.getFirst(orh.getOrderItemShipGroups());
                
            	if (UtilValidate.isEmpty(userLogin))
            	{
            		userLogin = delegator.findByPrimaryKeyCache("UserLogin", UtilMisc.toMap("userLoginId", "admin"));
            		
            	}
                
            	for (Iterator<?> item = sc.iterator(); item.hasNext();) 
            	{
                	ShoppingCartItem sci = (ShoppingCartItem)item.next();
                	if (UtilValidate.isNotEmpty(sci.getShoppingListId()))
                	{
                		String shoppingListId=sci.getShoppingListId();
                        Map shoppingListItemCtx = UtilMisc.toMap("userLogin", userLogin);
                        shoppingListItemCtx.put("shoppingListId", shoppingListId);
                        shoppingListItemCtx.put("productId", sci.getProductId());
                        shoppingListItemCtx.put("quantity", sci.getQuantity());
                        Map shoppingListItemResp = null;
                        try 
                        {
                            shoppingListItemResp = dispatcher.runSync("createShoppingListItem", shoppingListItemCtx);
                            GenericValue shoppingListItem = delegator.findByPrimaryKey("ShoppingListItem", UtilMisc.toMap("shoppingListId", shoppingListId,"shoppingListItemSeqId", (String) shoppingListItemResp.get("shoppingListItemSeqId")));
                            shoppingListItem.set("modifiedPrice", sci.getDisplayPrice());
                            shoppingListItem.store();
                        } 
                        catch (GenericServiceException e) 
                        {
                            Debug.logError(e, module);
                        }
                        

                        Map shoppingListCtx = new HashMap();
                        shoppingListCtx.put("shipmentMethodTypeId", shipGroup.get("shipmentMethodTypeId"));
                        shoppingListCtx.put("carrierRoleTypeId", shipGroup.get("carrierRoleTypeId"));
                        shoppingListCtx.put("carrierPartyId", shipGroup.get("carrierPartyId"));
                        shoppingListCtx.put("contactMechId", shipGroup.get("contactMechId"));
                        shoppingListCtx.put("paymentMethodId", paymentPref.get("paymentMethodId"));
                        shoppingListCtx.put("currencyUom", orh.getCurrency());
                        shoppingListCtx.put("isActive", "Y");
                        shoppingListCtx.put("startDateTime", UtilDateTime.nowTimestamp());
                        shoppingListCtx.put("lastOrderedDate", UtilDateTime.nowTimestamp());
                        shoppingListCtx.put("frequency", new Integer(4));
                        shoppingListCtx.put("intervalNumber", new Integer(PARAMETERS_RECURRENCE.getString("FREQUENCY")));
                        shoppingListCtx.put("shoppingListId", shoppingListId);
                        shoppingListCtx.put("userLogin", userLogin);
                        
                        Map shoppingListResp = null;
                        try 
                        {
                        	shoppingListResp = dispatcher.runSync("updateShoppingList", shoppingListCtx);
                        	
                        }
                        catch (GenericServiceException e) 
                        {
                            Debug.logError(e, module);
                        }
                	}
            	}
                
        	}

        } 
        catch (Exception e)
        {
            Debug.logError(e, "Problems creating new ShoppingList From Shopping Cart", module);
        	  
        }
        
        String result = "success";
        
        return result;
        
    }
    
    public static String processOrderAdjustmentAttributes(HttpServletRequest request, HttpServletResponse response) {
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        GenericValue userLogin = (GenericValue) request.getSession().getAttribute("userLogin");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        String orderId = sc.getOrderId();
        HttpSession session = request.getSession();
    	List orderAdjustmentAttributeList = (List) session.getAttribute("orderAdjustmentAttributeList");
    	List orderAdjustmentList = FastList.newInstance();
    	String result = "success";
    	
    	if (UtilValidate.isNotEmpty(orderId))
    	{
    		GenericValue orderHeader = null;
    		try
    		{
    			orderHeader = delegator.findByPrimaryKey("OrderHeader", UtilMisc.toMap("orderId", orderId));
	    	} 
    		catch (Exception e) 
	    	{
	            Debug.logError(e, module);
	        }
        	if (UtilValidate.isNotEmpty(orderHeader))
        	{
        		try
        		{
        			orderAdjustmentList = orderHeader.getRelated("OrderAdjustment");
        		}
        		catch (Exception e) 
    	    	{
    	            Debug.logError(e, module);
    	        }
        	}
        	
        	if (UtilValidate.isNotEmpty(orderAdjustmentList) && UtilValidate.isNotEmpty(orderAdjustmentAttributeList))
        	{
    	    	for(Object orderAdjustmentAttributeInfo : orderAdjustmentAttributeList)
    	    	{
    	    		Map orderAdjustmentAttributeInfoMap = (Map)orderAdjustmentAttributeInfo;
    	    		String loyaltyPointsIndex = (String) orderAdjustmentAttributeInfoMap.get("INDEX");
    	    		String loyaltyPointsAmount = (String) orderAdjustmentAttributeInfoMap.get("ADJUST_POINTS");
    	    		String adjustMethod = (String) orderAdjustmentAttributeInfoMap.get("ADJUST_METHOD");
    	            String loyaltyPointsId = (String) orderAdjustmentAttributeInfoMap.get("MEMBER_ID");
    	            String checkoutLoyaltyConversion = (String) orderAdjustmentAttributeInfoMap.get("CONVERSION_FACTOR");
    	            String expDate = (String) orderAdjustmentAttributeInfoMap.get("EXP_DATE");
    	            String currencyAmount = (String) orderAdjustmentAttributeInfoMap.get("CURRENCY_AMOUNT");
    	            BigDecimal currencyAmountBD = BigDecimal.ZERO;
    	            if (UtilValidate.isNotEmpty(currencyAmount)) 
    	            {
    	        		try 
    	                {
    	        			currencyAmountBD = new BigDecimal(currencyAmount);
    	                } 
    	                catch (NumberFormatException nfe) 
    	                {
    	                	Debug.logError(nfe, "Problems converting currencyAmount to BigDecimal", module);
    	                	currencyAmountBD = BigDecimal.ZERO;
    	                }
    	            }
    	            int loyaltyPointsIndexInt = -1;
    	            try {
    	            	loyaltyPointsIndexInt = Integer.parseInt(loyaltyPointsIndex);
    	            } 
    	            catch (Exception e) 
    	            {
    	                Debug.logError(e, module);
    	            }
    	            
    	        	GenericValue orderLoyaltyAdj = (GenericValue) orderAdjustmentList.get(loyaltyPointsIndexInt);
    	        	if (UtilValidate.isNotEmpty(orderLoyaltyAdj))
    	        	{
    	        		String orderAdjustmentId = (String) orderLoyaltyAdj.getString("orderAdjustmentId");
    	        		orderAdjustmentAttributeInfoMap.put("ORDER_ADJUSTMENT_ID", orderAdjustmentId);
    	        		try
    	                {
    		        		if (UtilValidate.isNotEmpty(loyaltyPointsAmount))
    		            	{
    		            		GenericValue orderAdjustmentAttr = delegator.makeValue("OrderAdjustmentAttribute");
    		            		orderAdjustmentAttr.set("orderAdjustmentId", orderAdjustmentId);
    		            		orderAdjustmentAttr.set("attrName", "ADJUST_METHOD");
    		            		orderAdjustmentAttr.set("attrValue", adjustMethod);
    		            		orderAdjustmentAttr.create();
    		            	}
    		        		
    		        		if (UtilValidate.isNotEmpty(loyaltyPointsId))
    		            	{
    		            		GenericValue orderAdjustmentAttr = delegator.makeValue("OrderAdjustmentAttribute");
    		            		orderAdjustmentAttr.set("orderAdjustmentId", orderAdjustmentId);
    		            		orderAdjustmentAttr.set("attrName", "MEMBER_ID");
    		            		orderAdjustmentAttr.set("attrValue", loyaltyPointsId);
    		            		orderAdjustmentAttr.create();
    		            	}
    		        		
    		        		if (UtilValidate.isNotEmpty(currencyAmount))
    		            	{
    		            		GenericValue orderAdjustmentAttr = delegator.makeValue("OrderAdjustmentAttribute");
    		            		orderAdjustmentAttr.set("orderAdjustmentId", orderAdjustmentId);
    		            		orderAdjustmentAttr.set("attrName", "ADJUST_POINTS");
    		            		orderAdjustmentAttr.set("attrValue", currencyAmount);
    		            		orderAdjustmentAttr.create();
    		            	}
    		        		
    		        		if (UtilValidate.isNotEmpty(expDate))
    		            	{
    		            		GenericValue orderAdjustmentAttr = delegator.makeValue("OrderAdjustmentAttribute");
    		            		orderAdjustmentAttr.set("orderAdjustmentId", orderAdjustmentId);
    		            		orderAdjustmentAttr.set("attrName", "EXP_DATE");
    		            		orderAdjustmentAttr.set("attrValue", expDate);
    		            		orderAdjustmentAttr.create();
    		            	}
    		        		
    		        		if (UtilValidate.isNotEmpty(checkoutLoyaltyConversion))
    		            	{
    		            		GenericValue orderAdjustmentAttr = delegator.makeValue("OrderAdjustmentAttribute");
    		            		orderAdjustmentAttr.set("orderAdjustmentId", orderAdjustmentId);
    		            		orderAdjustmentAttr.set("attrName", "CONVERSION_FACTOR");
    		            		orderAdjustmentAttr.set("attrValue", checkoutLoyaltyConversion);
    		            		orderAdjustmentAttr.create();
    		            	}
    	                }
    	        		catch (Exception e)
    	        		{
    	        			Debug.logError(e, "Problems creating new OrderAdjustmentAttribute", module);
    	                    return "error";
    	                }
    	        	}
    	    	}
        	}
    	}
    	
        return "success";
    }
    
    public static String redeemMemberLoyaltyPoints(HttpServletRequest request, HttpServletResponse response) {
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        String orderId = sc.getOrderId();
        HttpSession session = request.getSession();
    	List orderAdjustmentAttributeList = (List) session.getAttribute("orderAdjustmentAttributeList");
    	String result = "success";
    	
    	if (UtilValidate.isNotEmpty(orderId) && UtilValidate.isNotEmpty(orderAdjustmentAttributeList))
    	{
    		//Call service to reduce user Loyatly points in Users Account
    		Map serviceContext = FastMap.newInstance();
	    	serviceContext.put("orderId", orderId);
	    	serviceContext.put("orderAdjustmentAttributeList", orderAdjustmentAttributeList);
	    	try 
	    	{            
	    		dispatcher.runSync("redeemLoyaltyPoints", serviceContext);
	        } 
	    	catch (Exception e) 
	    	{
	            String errMsg = "Error when trying to reducing loyalty points :" + e.toString();
	            Debug.logError(e, errMsg, module);
	            return "error";
	        }
	    	session.removeAttribute("orderAdjustmentAttributeList");
    	}
    	
        return "success";
    }
}