<#if !pdpSelectMultiVariant?exists || (pdpSelectMultiVariant?has_content && !((pdpSelectMultiVariant.toUpperCase() == "QTY") || (pdpSelectMultiVariant.toUpperCase() == "CHECKBOX"))) >
  <li class="${request.getAttribute("attributeClass")!}">
    <div>
      <#if Static["com.osafe.util.Util"].isNumber(PDP_QTY_DEFAULT) >
        <#assign PDP_QTY_DEFAULT = PDP_QTY_DEFAULT!"" />
      <#else>  
        <#assign PDP_QTY_DEFAULT = 1 />
      </#if>
      <#if inStock>
        <label>${uiLabelMap.QuantityLabel}:</label>
        <input type="text" class="quantity" size="5" name="quantity" value=${parameters.quantity!PDP_QTY_DEFAULT!1} maxlength="5"/>
      <#elseif !isSellable>
        <label>${uiLabelMap.QuantityLabel}:</label>
        <input type="text" class="quantity" size="5" name="quantity" value=${parameters.quantity!PDP_QTY_DEFAULT!1} maxlength="5" disabled="disabled"/>
      </#if>
    </div>
  </li>
</#if>