<#if (!Static["com.osafe.util.Util"].isProductStoreParmTrue(request,"CHECKOUT_SUPPRESS_TAX_IF_ZERO")) || (orderTaxTotal?has_content && (orderTaxTotal &gt; 0))>
<li class="${request.getAttribute("attributeClass")!}">
   <div>
        <label>${uiLabelMap.SalesTaxCaption}</label>
        <span><@ofbizCurrency amount=orderTaxTotal rounding=globalContext.currencyRounding isoCode=currencyUom/></span>
   </div>
</li>
</#if>
