<#if paymentMethods?has_content>
<div class="${request.getAttribute("attributeClass")!}">
 <div class="displayBoxList paymentInformation">
  <div class="displayBox">
   <h3>${uiLabelMap.PaymentInformationHeading}</h3>
    <#list paymentMethods as paymentMethod>
           <#assign orderPaymentPreferences = paymentMethod.getRelated("OrderPaymentPreference")>
           <#assign orderPaymentPreference = ""/>
           <#if orderPaymentPreferences?has_content>
                <#assign orderPaymentPreference = orderPaymentPreferences[0]!"">
           </#if>
              <#-- credit card info -->
          <#if paymentMethod.paymentMethodTypeId?has_content && orderPaymentPreference?has_content>
	          <#if "CREDIT_CARD" == paymentMethod.paymentMethodTypeId>
		               <#assign orderPaymentPreferences = paymentMethod.getRelated("OrderPaymentPreference")>
		               <#assign orderPaymentPreference = ""/>
		               <#if orderPaymentPreferences?has_content>
		                    <#assign orderPaymentPreference = orderPaymentPreferences[0]!"">
		               </#if>
		                <#assign creditCard = paymentMethod.getRelatedOne("CreditCard")>
		                <#-- create a display version of the card where all but the last four digits are * -->
		                <#assign cardNumberDisplay = "">
		                <#assign cardNumber = creditCard.cardNumber?if_exists>
		                <#if cardNumber?has_content>
		                    <#assign size = cardNumber?length - 4>
		                    <#if (size > 0)>
		                        <#list 0 .. size-1 as foo>
		                            <#assign cardNumberDisplay = cardNumberDisplay + "X">
		                        </#list>
		                        <#assign cardNumberDisplay = cardNumberDisplay + "-" + cardNumber[size .. size + 3]>
		                    <#else>
		                        <#-- but if the card number has less than four digits (ie, it was entered incorrectly), display it in full -->
		                        <#assign cardNumberDisplay = cardNumber>
		                    </#if>
		                </#if>
	                   <#if creditCard?has_content>
				          <ul class="displayDetail creditCardInfo">
		                    <#if creditCardTypesMap[creditCard.cardType]?has_content>
				             <li>
				              <div>
				                <label for="cardType">${uiLabelMap.CardTypeCaption}</label>
				                <span>${creditCardTypesMap[creditCard.cardType]!""}</span>
				              </div>
				             </li>
				            </#if>
		                    <#if cardNumberDisplay?has_content>
				             <li>
				              <div>
				                <label for="cardNumber">${uiLabelMap.CardNumberCaption}</label>
				                <span>${cardNumberDisplay}</span>
				              </div>
				             </li>
		                    </#if>
		                    <#if creditCard.expireDate?has_content>
				             <li>
				              <div>
				                <label for="expMonth">${uiLabelMap.ExpDateCaption}</label>
				                <span>${creditCard.expireDate}</span>
				              </div>
				             </li>
		                    </#if>
			                 <li>
			                     <div>
			                        <label for="amount">${uiLabelMap.AmountCaption}</label>
			                        <span>
			                            <@ofbizCurrency amount=orderPaymentPreference.maxAmount isoCode=currencyUom rounding=globalContext.currencyRounding/>
			                        </span>
			                     </div>
			                 </li>
				          </ul>
				       </#if>
	          <#elseif "EXT_PAYPAL" == paymentMethod.paymentMethodTypeId>
			          <ul class="displayDetail payPalInfo">
			             <li>
			              <div>
			                <label for="paypalImage">${uiLabelMap.PayPalOnlyCaption}</label>
			                <span><img class="payPalImg" alt="PayPal" src="/osafe_theme/images/icon/paypal_wider.gif"/></span>
			              </div>
			             </li>
			             <li>
			              <div>
			                <label for="amount">${uiLabelMap.AmountCaption}</label>
			                <span>${orderPaymentPreference.maxAmount}</span>
			              </div>
			             </li>
			          </ul>
	          <#elseif "SAGEPAY_TOKEN" == paymentMethod.paymentMethodTypeId>
	               <#assign creditCard = paymentMethod.getRelatedOne("CreditCard")>
	               <#if creditCard?has_content>
			          <ul class="displayDetail creditCardInfo">
	                    <#if creditCardTypesMap[creditCard.cardType]?has_content>
			             <li>
			              <div>
			                <label for="cardType">${uiLabelMap.CardTypeCaption}</label>
			                <span>${creditCardTypesMap[creditCard.cardType]!""}</span>
			              </div>
			             </li>
			            </#if>
			          </ul>
	               </#if>
	          <#elseif "EXT_EBS" == paymentMethod.paymentMethodTypeId>
	                <#-- ebs info -->
			          <ul class="displayDetail ebsInfo">
			             <li>
			              <div>
	                        <h4>${uiLabelMap.EBSHeading}</h4>
			                <label for="ebsImage">${uiLabelMap.EBSOnlyCaption}</label>
			                <span><img class="ebsImage" alt="ebs" src="http://www.ebs.in/images/logo_ebs.png"></span>
			              </div>
			             </li>
			             <li>
			              <div>
			                <label for="amount">${uiLabelMap.AmountCaption}</label>
			                <span>${orderPaymentPreference.maxAmount}</span>
			              </div>
			             </li>
			          </ul>
	          <#elseif "EXT_PAYNETZ" == paymentMethod.paymentMethodTypeId>
	                  <ul class="displayDetail payNetzInfo">
	                     <li>
	                      <div>
	                        <h4>${uiLabelMap.PayNetzHeading}</h4>
	                        <label for="payNetzImage">${uiLabelMap.PayNetZOnlyCaption}</label>
	                        <span><img class="payNetzImage" alt="payNetz" src="http://www.atomtech.in/images/logo.png"></span>
	                      </div>
	                     </li>
	                     <li>
	                      <div>
	                        <label for="amount">${uiLabelMap.AmountCaption}</label>
	                        <span>${orderPaymentPreference.maxAmount}</span>
	                      </div>
	                     </li>
	                  </ul>
	           <#elseif "GIFT_CARD" == paymentMethod.paymentMethodTypeId >
	                <#assign giftCard = paymentMethod.getRelatedOne("GiftCard")?if_exists>
	                <#if giftCard?has_content>
			          <ul class="displayDetail giftCardInfo">
		                 <li>
		                     <div>
		                         <label for="cardNumber">${uiLabelMap.GiftCardNumberCaption}</label>
		                         <span>${giftCard.cardNumber!""}</span>
		                     </div>
		                 </li>
		                 <li>
		                     <div>
		                        <label for="amount">${uiLabelMap.AmountCaption}</label>
		                        <span>
		                            <@ofbizCurrency amount=orderPaymentPreference.maxAmount isoCode=currencyUom rounding=globalContext.currencyRounding/>
		                        </span>
		                     </div>
		                 </li>
	                 </ul>
	                </#if>
	            <#elseif "EXT_COD" == paymentMethod.paymentMethodTypeId>
			          <ul class="displayDetail codInfo">
		                 <li>
		                     <div>
		                         <label>${uiLabelMap.PayInStoreLabel}</label>
		                         <span>&nbsp;</span>
		                     </div>
		                 </li>
		                 <li>
		                     <div>
		                        <label for="amount">${uiLabelMap.AmountCaption}</label>
		                        <span>
		                            <@ofbizCurrency amount=orderPaymentPreference.maxAmount isoCode=currencyUom rounding=globalContext.currencyRounding/>
		                        </span>
		                     </div>
		                 </li>
	                 </ul>
	            <#else>
			          <ul class="displayDetail payInfo">
		                 <li>
		                     <div>
		                         <label>${paymentMethod.paymentMethodTypeId}</label>
		                         <span>&nbsp;</span>
		                     </div>
		                 </li>
		                 <li>
		                     <div>
		                        <label for="amount">${uiLabelMap.AmountCaption}</label>
		                        <span>
		                            <@ofbizCurrency amount=orderPaymentPreference.maxAmount isoCode=currencyUom rounding=globalContext.currencyRounding/>
		                        </span>
		                     </div>
		                 </li>
	                 </ul>
	            </#if>
	        </#if>
        </#list>
          
  </div>          
 </div>
</div>
</#if>
  
 
