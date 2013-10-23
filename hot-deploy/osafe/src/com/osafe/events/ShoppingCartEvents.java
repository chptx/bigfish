package com.osafe.events;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;  
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import javolution.util.FastList;
import javolution.util.FastMap;
import org.ofbiz.base.util.Debug;
import org.ofbiz.base.util.StringUtil;
import org.ofbiz.base.util.UtilHttp;
import org.ofbiz.base.util.UtilMisc;
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
import org.ofbiz.product.product.ProductContentWrapper;  
import org.ofbiz.product.store.ProductStoreWorker;
import org.apache.commons.lang.StringEscapeUtils;
import com.osafe.util.Util; 
import org.ofbiz.order.shoppingcart.product.ProductPromoWorker;  

public class ShoppingCartEvents {
	
    public static final String label_resource = "OSafeUiLabels";
    public static String module = ShoppingCartEvents.class.getName();

    public static String setPaymentMethodOnCart(HttpServletRequest request, HttpServletResponse response) 
    {
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        String securityCode = request.getParameter("verificationNo");
        
        if (sc.items().size() > 0) 
        {
            Map selectedPaymentMethods = new HashMap();
            Map paymentMethodInfo = FastMap.newInstance();
            List singleUsePayments = new ArrayList();
            paymentMethodInfo.put("amount", null);
            if (UtilValidate.isNotEmpty(securityCode))
            {
                paymentMethodInfo.put("securityCode", securityCode);
            }
            String paymentMethodId = (String) request.getAttribute("paymentMethodId");
            selectedPaymentMethods.put(paymentMethodId, paymentMethodInfo);
            sc.addPayment(paymentMethodId);
            CheckOutHelper checkOutHelper = new CheckOutHelper(dispatcher, delegator, sc);
            checkOutHelper.setCheckOutPayment(selectedPaymentMethods, singleUsePayments, null);
            
            //if shipping does not apply, do not calculate shipping (skip to calculating tax)
            if(!sc.shippingApplies())
            {
            	return "calcTax";
            }
        }

        return "success";
    }

    public static String resetPaymentMethod(HttpServletRequest request, HttpServletResponse response) 
    {
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        List<GenericValue> paymentMethods = sc.getPaymentMethods();
        if (UtilValidate.isNotEmpty(paymentMethods)) 
        {
    		for(GenericValue paymentMethod : paymentMethods) 
            {
                CartPaymentInfo paymentInfo = sc.getPaymentInfo(paymentMethod.getString("paymentMethodId"));
                if (!paymentInfo.paymentMethodTypeId.equalsIgnoreCase("GIFT_CARD"))
                {
                    paymentInfo.amount = null;
                }
            }
        }
        if(UtilValidate.isEmpty(sc.items())) 
        {
            return org.ofbiz.order.shoppingcart.ShoppingCartEvents.clearCart(request, response);
        }
        return "success";
    }

    public static String setProductCategoryId(HttpServletRequest request, HttpServletResponse response) 
    {
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        String productCategoryId = request.getParameter("add_category_id");
        String productId = request.getParameter("add_product_id");
        if(UtilValidate.isNotEmpty(productCategoryId) && UtilValidate.isNotEmpty(productId)) 
        {
        	for (Iterator<?> item = sc.iterator(); item.hasNext();) 
        	{
            	ShoppingCartItem sci = (ShoppingCartItem)item.next();
            	if (sci.getProductId().equals(productId)) 
            	{
            		sci.setProductCategoryId(productCategoryId);
            		break;
            	}
            }	
        }
        return "success";
    }
    
    public static String addMultiItemsToCart(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map<String, Object> context = FastMap.newInstance(); 
    	Map<String, Object> params = UtilHttp.getParameterMap(request);
        String categoryId = (String) params.get("add_category_id");
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        ShoppingCartHelper cartHelper = new ShoppingCartHelper(delegator, dispatcher, sc); 
        
        for(Entry<String, Object> entry : params.entrySet()) 
        {
            String parameterName = entry.getKey();
        	BigDecimal quantity = BigDecimal.ZERO;
        	String productId = null;
        	String quantityStr = null;
        	if (parameterName.toUpperCase().startsWith("ADD_MULTI_PRODUCT_ID"))
        	{
        		productId = (String) entry.getValue();
        		//get the index so that we can get the related quantity
        		int underscorePos = parameterName.lastIndexOf('_');
        		if (underscorePos >= 0) 
        		{
        			try 
        			{
        				String indexStr = parameterName.substring(underscorePos + 1);
                        int index = Integer.parseInt(indexStr);
                        quantityStr = (String) params.get("add_multi_product_quantity_"+index);
                        if (UtilValidate.isNotEmpty(quantityStr)) 
                        {
                            try 
                            {
                                quantity = new BigDecimal(quantityStr);
                            } 
                            catch (NumberFormatException nfe) 
                            {
                                quantity = BigDecimal.ZERO;
                            }
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
        		if(UtilValidate.isNotEmpty(productId) && quantity.compareTo(BigDecimal.ZERO) > 0)
                {
                	// add item and quantity to cart using the addToCart method
                	cartHelper.addToCart(null, null, null, productId, categoryId, null, null, null, null, quantity, null, null, null, null, null, null, null, null, null, context, null);
                }
        	}
        }
        return "success";
    }
    
    public static String addMultiItemsToWishlist(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map<String, Object> context = FastMap.newInstance(); 
    	Map<String, Object> params = UtilHttp.getParameterMap(request);
        String categoryId = (String) params.get("add_category_id");
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        ShoppingCartHelper cartHelper = new ShoppingCartHelper(delegator, dispatcher, sc); 
        
        for(Entry<String, Object> entry : params.entrySet()) 
        {
            String parameterName = entry.getKey();
        	BigDecimal quantity = BigDecimal.ZERO;
        	String productId = null;
        	String quantityStr = null;
        	if (parameterName.toUpperCase().startsWith("ADD_MULTI_PRODUCT_ID"))
        	{
        		productId = (String) entry.getValue();
        		//get the index so that we can get the related quantity
        		int underscorePos = parameterName.lastIndexOf('_');
        		if (underscorePos >= 0) 
        		{
        			try 
        			{
        				String indexStr = parameterName.substring(underscorePos + 1);
                        int index = Integer.parseInt(indexStr);
                        quantityStr = (String) params.get("add_multi_product_quantity_"+index);
                        if (UtilValidate.isNotEmpty(quantityStr)) 
                        {
                            try 
                            {
                                quantity = new BigDecimal(quantityStr);
                            } 
                            catch (NumberFormatException nfe) 
                            {
                                quantity = BigDecimal.ZERO;
                            }
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
        		if(UtilValidate.isNotEmpty(productId) && quantity.compareTo(BigDecimal.ZERO) > 0)
                {
        			request.setAttribute("add_product_id", productId);
        			request.setAttribute("add_category_id", categoryId);
        			WishListEvents.addToWishList(request, response);
                }
        	}
        }
        return "success";
    }
    
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
    
    
    
    public static String addPlpItemToCart(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map<String, Object> context = FastMap.newInstance(); 
    	Map<String, Object> params = UtilHttp.getParameterMap(request);
        String productId = (String) params.get("plp_add_product_id");
        String quantityStr = (String) params.get("plp_qty");
        String categoryId = (String) params.get("plp_add_category_id");
        String productName = (String) params.get("plp_add_product_name");
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        ShoppingCartHelper cartHelper = new ShoppingCartHelper(delegator, dispatcher, sc); 
        Locale locale = UtilHttp.getLocale(request);
        
        //validate quantity value
        BigDecimal quantity = BigDecimal.ZERO;
        if (UtilValidate.isNotEmpty(quantityStr)) 
        {
            try 
            {
                quantity = new BigDecimal(quantityStr);
            } 
            catch (NumberFormatException nfe) 
            {
                quantity = BigDecimal.ZERO;
            }
        }
        
        if(UtilValidate.isNotEmpty(productId) && quantity.compareTo(BigDecimal.ZERO) > 0)
        {
        	String last_page_productId = (String) params.get("add_product_id");
        	request.setAttribute("productCategoryId", categoryId);
        	request.setAttribute("product_id", last_page_productId);
        	// add item and quantity to cart using the addToCart method
        	cartHelper.addToCart(null, null, null, productId, categoryId, null, null, null, null, quantity, null, null, null, null, null, null, null, null, null, context, null);
        	
        	//Get values for success message variables
        	Map<String, String> messageMap = UtilMisc.toMap("productName", productName);
        	String urlLabel = UtilProperties.getMessage(ShoppingCartEvents.label_resource, "ShowCartLink", locale); 
        	messageMap.put("cartLink", "<a href='eCommerceShowcart'>"+ urlLabel +"</a>");
        	//Set the success message
        	String successMess = UtilProperties.getMessage(ShoppingCartEvents.label_resource, "AddToCartPLPSuccess", messageMap, locale);    
            List osafeSuccessMessageList = UtilMisc.toList(successMess);
            request.setAttribute("osafeSuccessMessageList", osafeSuccessMessageList);
        }
        
        return "success";
    }
    public static String addRecurrenceItemToCart(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map<String, Object> context = FastMap.newInstance(); 
    	Map<String, Object> params = UtilHttp.getParameterMap(request);
        String productId = (String) params.get("add_product_id");
        String quantityStr = (String) params.get("quantity");
        String categoryId = (String) params.get("add_category_id");
        String productName = (String) params.get("add_product_name");
        Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        ShoppingCart sc = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        ShoppingCartHelper cartHelper = new ShoppingCartHelper(delegator, dispatcher, sc); 
        Locale locale = UtilHttp.getLocale(request);
        
        //validate quantity value
        BigDecimal quantity = BigDecimal.ZERO;
        if (UtilValidate.isNotEmpty(quantityStr)) 
        {
            try 
            {
                quantity = new BigDecimal(quantityStr);
            } 
            catch (NumberFormatException nfe) 
            {
                quantity = BigDecimal.ZERO;
            }
        }
        
        
        if(UtilValidate.isNotEmpty(productId) && quantity.compareTo(BigDecimal.ZERO) > 0)
        {
        	// add item and quantity to cart using the addToCart method
        	cartHelper.addToCart(null, null, null, productId, categoryId, null, null, null, null, quantity, null, null, null, null, null, null, null, null, null, context, null);
        	for (Iterator<?> item = sc.iterator(); item.hasNext();) 
        	{
            	ShoppingCartItem sci = (ShoppingCartItem)item.next();
            	if (sci.getProductId().equals(productId)) 
            	{
            		if (sci.getRecurringDisplayPrice().compareTo(BigDecimal.ZERO) > 0)
            		{
                		sci.setBasePrice(sci.getRecurringDisplayPrice());
                		sci.setDisplayPrice(sci.getRecurringDisplayPrice());
                		sci.setIsModifiedPrice(true);
                		sci.setShoppingList("SLT_AUTO_REODR", "00001");
            		}
            		break;
            	}
            }	
        	
        }
        
        return "success";
    }
    
    public static String addLoyaltyPoints(HttpServletRequest request, HttpServletResponse response) 
    {
    	HttpSession session = request.getSession();
    	Delegator delegator = (Delegator) request.getAttribute("delegator");
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        Locale locale = UtilHttp.getLocale(request);
        ShoppingCart cart = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        Map parameters = UtilHttp.getParameterMap(request);
        String productStoreId = ProductStoreWorker.getProductStoreId(request);
        String loyaltyPointsId = (String) parameters.get("loyaltyPointsId");
    	String checkoutLoyaltyMethod = Util.getProductStoreParm(request, "CHECKOUT_LOYALTY_METHOD");  
    	String checkoutLoyaltyConversion = Util.getProductStoreParm(request, "CHECKOUT_LOYALTY_CONVERSION"); 
    	BigDecimal checkoutLoyaltyConversionBD = BigDecimal.ZERO;
    	if (UtilValidate.isNotEmpty(checkoutLoyaltyConversion) && UtilValidate.isInteger(checkoutLoyaltyConversion)) 
        {
    		try 
            {
    			checkoutLoyaltyConversionBD = new BigDecimal(checkoutLoyaltyConversion);
            } 
            catch (NumberFormatException nfe) 
            {
            	Debug.logError(nfe, "Problems converting amount to BigDecimal", module);
            	checkoutLoyaltyConversionBD = BigDecimal.ONE;
            }
        }
    	BigDecimal totalLoyaltyPointsAmountBD = (BigDecimal) request.getAttribute("loyaltyPointsAmount");
    	String totalLoyaltyPointsAmountStr = "";
    	if (UtilValidate.isNotEmpty(totalLoyaltyPointsAmountBD)) 
        {
    		totalLoyaltyPointsAmountStr = totalLoyaltyPointsAmountBD.toString();
        }
    	
    	List orderAdjustmentAttributeList = (List) session.getAttribute("orderAdjustmentAttributeList");
    	if(UtilValidate.isEmpty(orderAdjustmentAttributeList))
    	{
    		orderAdjustmentAttributeList = FastList.newInstance();
    	}
    	else
    	{
    		for(Object orderAdjustmentAttributeInfo : orderAdjustmentAttributeList)
	    	{
	    		Map orderAdjustmentAttributeInfoMap = (Map)orderAdjustmentAttributeInfo;
	    		String adjustmentType = (String) orderAdjustmentAttributeInfoMap.get("ADJUST_TYPE");
	    		if(UtilValidate.isNotEmpty(adjustmentType) && "LOYALTY_POINTS".equalsIgnoreCase(adjustmentType))
	    		{
	    			return "success";
	    		}
	    	}
    	}
    	//retrieve loyalty points information
    	Map serviceContext = FastMap.newInstance();
    	serviceContext.put("loyaltyPointsId", loyaltyPointsId);
    	serviceContext.put("productStoreId", productStoreId);
    	Map loyaltyInfoMap = FastMap.newInstance();
    	try 
    	{            
    		loyaltyInfoMap = dispatcher.runSync("getLoyaltyPointsInfoMap", serviceContext);
        } 
    	catch (Exception e) 
    	{
            String errMsg = "Error when retriving loyalty points information :" + e.toString();
            Debug.logError(e, errMsg, module);
            return "error";
        }
    	
    	String expDate = "";
    	if(UtilValidate.isNotEmpty(loyaltyInfoMap))
    	{
    		expDate = (String) loyaltyInfoMap.get("expDate");
    	}
    	
    	//convert Total Loyalty Points Amount to Currency
    	serviceContext = FastMap.newInstance();
    	serviceContext.put("loyaltyPointsAmount", totalLoyaltyPointsAmountBD);
    	serviceContext.put("checkoutLoyaltyConversion", checkoutLoyaltyConversionBD);
    	Map loyaltyConversionMap = FastMap.newInstance();
    	try 
    	{            
    		loyaltyConversionMap = dispatcher.runSync("convertLoyaltyPoints", serviceContext);
        } 
    	catch (Exception e) 
    	{
            String errMsg = "Error when converting loyalty points to currency :" + e.toString();
            Debug.logError(e, errMsg, module);
            return "error";
        }
    	
    	BigDecimal totalLoyaltyPointsCurrencyBD = BigDecimal.ZERO;
    	String totalLoyaltyPointsCurrencyStr = "";
    	if(UtilValidate.isNotEmpty(loyaltyConversionMap))
    	{
    		totalLoyaltyPointsCurrencyBD = (BigDecimal) loyaltyConversionMap.get("loyaltyPointsCurrency");
    		totalLoyaltyPointsCurrencyStr = totalLoyaltyPointsCurrencyBD.toString();
    	}
    	
    	//Add Loyalty Points Adjustment to the Cart and add orderAdjustmentAttributeList Object to session
    	if(UtilValidate.isNotEmpty(cart) && cart.size() > 0)
    	{
    		//initially set the applied values to the totals
    		BigDecimal loyaltyPointsCurrencyBD = totalLoyaltyPointsCurrencyBD;
    		String loyaltyPointsCurrencyStr = totalLoyaltyPointsCurrencyStr;
    		BigDecimal loyaltyPointsAmountBD = totalLoyaltyPointsAmountBD;
    		String loyaltyPointsAmountStr = totalLoyaltyPointsAmountStr;
    		//compare loyaltyPointsCurrency applied by Loyalty Points to the balance left on the order
    		BigDecimal cartGrandTotal = cart.getGrandTotal().stripTrailingZeros();
    		if ((loyaltyPointsCurrencyBD.compareTo(cartGrandTotal) > 0)) 
            {
    			//show warning mesage
    			session.setAttribute("showLoyaltyPointsAdjustedWarning", "Y");
    			request.setAttribute("showLoyaltyPointsAdjustedWarning", "Y");
    			loyaltyPointsCurrencyBD = cartGrandTotal;
    			loyaltyPointsCurrencyStr = loyaltyPointsCurrencyBD.toString();
    			
    			//convert Currency to Loyalty Points Amount
            	serviceContext = FastMap.newInstance();
            	serviceContext.put("loyaltyPointsCurrency", loyaltyPointsCurrencyBD);
            	serviceContext.put("checkoutLoyaltyConversion", checkoutLoyaltyConversionBD);
            	loyaltyConversionMap = FastMap.newInstance();
            	try 
            	{            
            		loyaltyConversionMap = dispatcher.runSync("convertCurrencyToLoyaltyPoints", serviceContext);
                } 
            	catch (Exception e) 
            	{
                    String errMsg = "Error when converting currency to loyalty points :" + e.toString();
                    Debug.logError(e, errMsg, module);
                    return "error";
                }
            	
            	if(UtilValidate.isNotEmpty(loyaltyConversionMap))
            	{
            		loyaltyPointsAmountBD = (BigDecimal) loyaltyConversionMap.get("loyaltyPointsAmount");
            		if (UtilValidate.isNotEmpty(loyaltyPointsAmountBD)) 
                    {
            			loyaltyPointsAmountStr = loyaltyPointsAmountBD.toString();
                    }
            	}
            	//String warningMess = UtilProperties.getMessage(ShoppingCartEvents.label_resource, "LoyaltyPointsExceedCartBalanceWarning", locale);    
                //List warningMessageList = UtilMisc.toList(warningMess);
                //request.setAttribute("warningMessageList", warningMessageList);
            }
    		else
    		{
    			//remove warning mesage if it exists
    			String showLoyaltyPointsAdjustedWarning = (String) session.getAttribute("showLoyaltyPointsAdjustedWarning");
    			if(UtilValidate.isNotEmpty(showLoyaltyPointsAdjustedWarning))
    			{
    				session.removeAttribute("showLoyaltyPointsAdjustedWarning");
    			}
    		}
    		
    		//negate the value so it can be applied to cart
    		BigDecimal loyaltyPointsCurrencyNegateBD = loyaltyPointsCurrencyBD.multiply(BigDecimal.valueOf(-1));
    		
    		//create orderAdjustment and apply to cart
    		GenericValue orderAdjustment = delegator.makeValue("OrderAdjustment");
            orderAdjustment.set("orderAdjustmentTypeId", "LOYALTY_POINTS");
            orderAdjustment.set("amount", loyaltyPointsCurrencyNegateBD);
            int indexOfAdjInt = cart.addAdjustment(orderAdjustment);
            String indexOfAdj = String.valueOf(indexOfAdjInt);
            
            Map<String, Object>  orderAdjustmentAttributeInfoMap = FastMap.newInstance();
            //create Order Adjustment Attributes to be saved to the order
            orderAdjustmentAttributeInfoMap.put("INDEX", indexOfAdj);
            orderAdjustmentAttributeInfoMap.put("ADJUST_TYPE", "LOYALTY_POINTS");
            orderAdjustmentAttributeInfoMap.put("ADJUST_METHOD", checkoutLoyaltyMethod);
            orderAdjustmentAttributeInfoMap.put("MEMBER_ID", loyaltyPointsId);
            orderAdjustmentAttributeInfoMap.put("ADJUST_POINTS", loyaltyPointsAmountStr);
            if (UtilValidate.isNotEmpty(expDate)) 
            {
            	orderAdjustmentAttributeInfoMap.put("EXP_DATE", expDate);
            }
            orderAdjustmentAttributeInfoMap.put("CONVERSION_FACTOR", checkoutLoyaltyConversion);
            orderAdjustmentAttributeInfoMap.put("CURRENCY_AMOUNT", loyaltyPointsCurrencyStr);
            //these Adjustment Attributes will not be saved to Order, but are used for processing
            orderAdjustmentAttributeInfoMap.put("TOTAL_POINTS", totalLoyaltyPointsAmountStr);
            orderAdjustmentAttributeInfoMap.put("TOTAL_AMOUNT", totalLoyaltyPointsCurrencyStr);
            
            //add to session object
            orderAdjustmentAttributeList.add(orderAdjustmentAttributeInfoMap);
            session.setAttribute("orderAdjustmentAttributeList", orderAdjustmentAttributeList);  
    	}
    	//code to calculate remaining user points
    	
    	//Send this request variable to updateCartOnChange
    	String doCartLoyalty = "N";
    	request.setAttribute("DO_CART_LOYALTY", doCartLoyalty);
    	return "success";
    }
    
    public static String removeLoyaltyPoints(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map parameters = UtilHttp.getParameterMap(request);
        HttpSession session = request.getSession();
    	List orderAdjustmentAttributeList = (List) session.getAttribute("orderAdjustmentAttributeList");
    	ShoppingCart cart = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
    	if(UtilValidate.isNotEmpty(cart))
        {
    		int cartAdjIndexCount = 0;
    		List cartAdjustments = cart.getAdjustments();
	    	for(Object cartAdjustmentObj : cartAdjustments)
	    	{
	    		GenericValue cartAdjustment = (GenericValue) cartAdjustmentObj;
	    		String cartAdjustmentTypeId = cartAdjustment.getString("orderAdjustmentTypeId");
	    		if(UtilValidate.isNotEmpty(cartAdjustmentTypeId) && "LOYALTY_POINTS".equalsIgnoreCase(cartAdjustmentTypeId))
	    		{
	    			cart.removeAdjustment(cartAdjIndexCount);
	    		}
	    		cartAdjIndexCount++;
	    	}
        }
    	if(UtilValidate.isNotEmpty(orderAdjustmentAttributeList))
    	{
    		int listIndexCount = 0;
	    	for(Object orderAdjustmentAttributeInfo : orderAdjustmentAttributeList)
	    	{
	    		Map orderAdjustmentAttributeInfoMap = (Map)orderAdjustmentAttributeInfo;
	    		String orderAdjType = (String) orderAdjustmentAttributeInfoMap.get("ADJUST_TYPE");
	    		if(UtilValidate.isNotEmpty(orderAdjType) && "LOYALTY_POINTS".equalsIgnoreCase(orderAdjType))
	    		{
	    			orderAdjustmentAttributeList.remove(listIndexCount);
	            }
	    		listIndexCount++;
	    	}
    	}
    	//Send this request variable to updateCartOnChange
    	String doCartLoyalty = "N";
    	request.setAttribute("DO_CART_LOYALTY", doCartLoyalty);
    	return "success";
    } 
    public static String updateLoyaltyPoints(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map parameters = UtilHttp.getParameterMap(request);
    	Locale locale = UtilHttp.getLocale(request);
        String loyaltyPointsAmountStr = (String) parameters.get("update_loyaltyPointsAmount");
        HttpSession session = request.getSession();
    	List orderAdjustmentAttributeList = (List) session.getAttribute("orderAdjustmentAttributeList");
    	ShoppingCart cart = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
    	LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
    	
    	BigDecimal loyaltyPointsAmountBD = new BigDecimal(loyaltyPointsAmountStr);

    	if(UtilValidate.isNotEmpty(cart))
        {
    		BigDecimal loyaltyPointsCurrencyBD = BigDecimal.ZERO;
    		for(Object orderAdjustmentAttributeInfo : orderAdjustmentAttributeList)
	    	{
	    		Map orderAdjustmentAttributeInfoMap = (Map)orderAdjustmentAttributeInfo;
	    		String orderAdjType = (String) orderAdjustmentAttributeInfoMap.get("ADJUST_TYPE");
	    		if(UtilValidate.isNotEmpty(orderAdjType) && "LOYALTY_POINTS".equalsIgnoreCase(orderAdjType))
	    		{
	    			String checkoutLoyaltyConversionStr = (String) orderAdjustmentAttributeInfoMap.get("CONVERSION_FACTOR");
	    			BigDecimal checkoutLoyaltyConversionBD = new BigDecimal(checkoutLoyaltyConversionStr);
	    			
	    			//convert Total Loyalty Points Amount to Currency
	    			Map serviceContext = FastMap.newInstance();
	    	    	serviceContext.put("loyaltyPointsAmount", loyaltyPointsAmountBD);
	    	    	serviceContext.put("checkoutLoyaltyConversion", checkoutLoyaltyConversionBD);
	    	    	Map loyaltyConversionMap = FastMap.newInstance();
	    	    	try 
	    	    	{            
	    	    		loyaltyConversionMap = dispatcher.runSync("convertLoyaltyPoints", serviceContext);
	    	        } 
	    	    	catch (Exception e) 
	    	    	{
	    	            String errMsg = "Error when converting loyalty points to currency :" + e.toString();
	    	            Debug.logError(e, errMsg, module);
	    	            return "error";
	    	        }
	    	    	
	    	    	String loyaltyPointsCurrencyStr = "";
	    	    	if(UtilValidate.isNotEmpty(loyaltyConversionMap))
	    	    	{
	    	    		loyaltyPointsCurrencyBD = (BigDecimal) loyaltyConversionMap.get("loyaltyPointsCurrency");
	    	    		loyaltyPointsCurrencyStr = loyaltyPointsCurrencyBD.toString();
	    	    	}
	    	    	String currentLoyaltyPointsCurrencyStr = (String) orderAdjustmentAttributeInfoMap.get("CURRENCY_AMOUNT");
    	    		BigDecimal currentLoyaltyPointsCurrencyBD = new BigDecimal(currentLoyaltyPointsCurrencyStr);
	    	    	BigDecimal cartGrandTotal = cart.getGrandTotal().add(currentLoyaltyPointsCurrencyBD).stripTrailingZeros();
	    	    	if(loyaltyPointsCurrencyBD.compareTo(cartGrandTotal) > 0) 
		            {
	    	    		//show warning mesage
	        			session.setAttribute("showLoyaltyPointsAdjustedWarning", "Y");
	        			request.setAttribute("showLoyaltyPointsAdjustedWarning", "Y");
		    			loyaltyPointsCurrencyBD = cartGrandTotal;
		    			loyaltyPointsCurrencyStr = loyaltyPointsCurrencyBD.toString();
		    			
		    			//convert Currency to Loyalty Points Amount
		            	serviceContext = FastMap.newInstance();
		            	serviceContext.put("loyaltyPointsCurrency", loyaltyPointsCurrencyBD);
		            	serviceContext.put("checkoutLoyaltyConversion", checkoutLoyaltyConversionBD);
		            	loyaltyConversionMap = FastMap.newInstance();
		            	try 
		            	{            
		            		loyaltyConversionMap = dispatcher.runSync("convertCurrencyToLoyaltyPoints", serviceContext);
		                } 
		            	catch (Exception e) 
		            	{
		                    String errMsg = "Error when converting currency to loyalty points :" + e.toString();
		                    Debug.logError(e, errMsg, module);
		                    return "error";
		                }
		            	
		            	if(UtilValidate.isNotEmpty(loyaltyConversionMap))
		            	{
		            		loyaltyPointsAmountBD = (BigDecimal) loyaltyConversionMap.get("loyaltyPointsAmount");
		            		if (UtilValidate.isNotEmpty(loyaltyPointsAmountBD)) 
		                    {
		            			loyaltyPointsAmountStr = loyaltyPointsAmountBD.toString();
		                    }
		            	}
		            	//String warningMess = UtilProperties.getMessage(ShoppingCartEvents.label_resource, "LoyaltyPointsRedeemedExceedCartBalanceWarning", locale);    
		                //List warningMessageList = UtilMisc.toList(warningMess);
		                //request.setAttribute("warningMessageList", warningMessageList);
		            }
	    	    	else
	        		{
	        			//remove warning mesage if it exists
	        			String showLoyaltyPointsAdjustedWarning = (String) session.getAttribute("showLoyaltyPointsAdjustedWarning");
	        			if(UtilValidate.isNotEmpty(showLoyaltyPointsAdjustedWarning))
	        			{
	        				session.removeAttribute("showLoyaltyPointsAdjustedWarning");
	        			}
	        		}
	    	    	orderAdjustmentAttributeInfoMap.put("ADJUST_POINTS", loyaltyPointsAmountStr);
	    			orderAdjustmentAttributeInfoMap.put("CURRENCY_AMOUNT", loyaltyPointsCurrencyStr);
	    			
	    		}
	    	}
    		
    		if(UtilValidate.isNotEmpty(loyaltyPointsCurrencyBD))
    		{
    			List cartAdjustments = cart.getAdjustments();
    			BigDecimal loyaltyPointsCurrencyNegateBD = loyaltyPointsCurrencyBD.multiply(BigDecimal.valueOf(-1));
        		for(Object cartAdjustmentObj : cartAdjustments)
    	    	{
        			GenericValue cartAdjustment = (GenericValue) cartAdjustmentObj;
        			String cartAdjustmentTypeId = cartAdjustment.getString("orderAdjustmentTypeId");
        			if(UtilValidate.isNotEmpty(cartAdjustmentTypeId) && "LOYALTY_POINTS".equalsIgnoreCase(cartAdjustmentTypeId))
        			{
        				cartAdjustment.set("amount", loyaltyPointsCurrencyNegateBD);
        			}
    	    	}
    		}
        }
    	//Send this request variable to updateCartOnChange
    	String doCartLoyalty = "N";
    	request.setAttribute("DO_CART_LOYALTY", doCartLoyalty);
    	return "success";
    } 
    public static String modifyLoyaltyPoints(HttpServletRequest request, HttpServletResponse response) 
    {
    	Map parameters = UtilHttp.getParameterMap(request);
        LocalDispatcher dispatcher = (LocalDispatcher) request.getAttribute("dispatcher");
        HttpSession session = request.getSession();
    	List orderAdjustmentAttributeList = (List) session.getAttribute("orderAdjustmentAttributeList");
    	ShoppingCart cart = org.ofbiz.order.shoppingcart.ShoppingCartEvents.getCartObject(request);
        
    	if(UtilValidate.isNotEmpty(cart) && cart.size() > 0)
        {
    		if(UtilValidate.isNotEmpty(orderAdjustmentAttributeList))
            {
	    		for(Object orderAdjustmentAttributeInfo : orderAdjustmentAttributeList)
		    	{
		    		Map orderAdjustmentAttributeInfoMap = (Map)orderAdjustmentAttributeInfo;
    	    		String adjustmentType = (String) orderAdjustmentAttributeInfoMap.get("ADJUST_TYPE");
    	    		if(UtilValidate.isNotEmpty(adjustmentType) && "LOYALTY_POINTS".equalsIgnoreCase(adjustmentType))
		    		{
    	    			String checkoutLoyaltyConversionStr = (String) orderAdjustmentAttributeInfoMap.get("CONVERSION_FACTOR");
    	    			BigDecimal checkoutLoyaltyConversionBD = new BigDecimal(checkoutLoyaltyConversionStr);
			    		String currentLoyaltyPointsCurrencyStr = (String) orderAdjustmentAttributeInfoMap.get("CURRENCY_AMOUNT");
        	    		BigDecimal currentLoyaltyPointsCurrencyBD = new BigDecimal(currentLoyaltyPointsCurrencyStr);
    	    	    	BigDecimal cartGrandTotal = cart.getGrandTotal().add(currentLoyaltyPointsCurrencyBD).stripTrailingZeros();
			    		if(currentLoyaltyPointsCurrencyBD.compareTo(cartGrandTotal) > 0) 
			            {
			    			//show warning mesage
			    			session.setAttribute("showLoyaltyPointsAdjustedWarning", "Y");
			    			request.setAttribute("showLoyaltyPointsAdjustedWarning", "Y");
			    			BigDecimal loyaltyPointsCurrencyBD = cartGrandTotal;
			    			String loyaltyPointsCurrencyStr = loyaltyPointsCurrencyBD.toString();
			    			
			    			//convert Currency to Loyalty Points Amount
			            	Map serviceContext = FastMap.newInstance();
			            	serviceContext.put("loyaltyPointsCurrency", loyaltyPointsCurrencyBD);
			            	serviceContext.put("checkoutLoyaltyConversion", checkoutLoyaltyConversionBD);
			            	Map loyaltyConversionMap = FastMap.newInstance();
			            	try 
			            	{            
			            		loyaltyConversionMap = dispatcher.runSync("convertCurrencyToLoyaltyPoints", serviceContext);
			                } 
			            	catch (Exception e) 
			            	{
			                    String errMsg = "Error when converting currency to loyalty points :" + e.toString();
			                    Debug.logError(e, errMsg, module);
			                    return "error";
			                }
			            	
			            	if(UtilValidate.isNotEmpty(loyaltyConversionMap))
			            	{
			            		BigDecimal loyaltyPointsAmountBD = (BigDecimal) loyaltyConversionMap.get("loyaltyPointsAmount");
			            		if (UtilValidate.isNotEmpty(loyaltyPointsAmountBD)) 
			                    {
			            			String loyaltyPointsAmountStr = loyaltyPointsAmountBD.toString();
			            			orderAdjustmentAttributeInfoMap.put("ADJUST_POINTS", loyaltyPointsAmountStr);
					            	orderAdjustmentAttributeInfoMap.put("CURRENCY_AMOUNT", loyaltyPointsCurrencyStr);
			            			
			            			List cartAdjustments = cart.getAdjustments();
			            			BigDecimal loyaltyPointsCurrencyNegateBD = loyaltyPointsCurrencyBD.multiply(BigDecimal.valueOf(-1));
			                		for(Object cartAdjustmentObj : cartAdjustments)
			            	    	{
			                			GenericValue cartAdjustment = (GenericValue) cartAdjustmentObj;
			                			String cartAdjustmentTypeId = cartAdjustment.getString("orderAdjustmentTypeId");
			                			if(UtilValidate.isNotEmpty(cartAdjustmentTypeId) && "LOYALTY_POINTS".equalsIgnoreCase(cartAdjustmentTypeId))
			                			{
			                				cartAdjustment.set("amount", loyaltyPointsCurrencyNegateBD);
			                			}
			            	    	}
			                    }
			            	}
			            }
			    		else
			    		{
			    			//remove warning mesage if it exists
			    			String showLoyaltyPointsAdjustedWarning = (String) session.getAttribute("showLoyaltyPointsAdjustedWarning");
			    			if(UtilValidate.isNotEmpty(showLoyaltyPointsAdjustedWarning))
			    			{
			    				session.removeAttribute("showLoyaltyPointsAdjustedWarning");
			    			}
			    		}
		    		}
		    	}
            }
        }
    	return "success";
    } 
}
