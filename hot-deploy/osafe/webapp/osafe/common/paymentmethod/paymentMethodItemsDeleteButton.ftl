<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <#assign cardNumber=savedCreditCard.cardNumber?if_exists/>
    <#assign cardNumberDisplay = "">
    <#assign size = cardNumber?length - 4>
    <#if (size > 0)>
        <#list 0 .. size-1 as charno>
           <#assign cardNumberDisplay = cardNumberDisplay + "*">
        </#list>
        <#assign cardNumberDisplay = cardNumberDisplay + "-">
        <#assign cardNumberDisplay = cardNumberDisplay + cardNumber[size .. size + 3]>
    <#else>
        <#assign cardNumberDisplay = cardNumber>
    </#if>
    <a class="standardBtn delete" href="javascript:deleteConfirm('${cardNumberDisplay}');" onclick="void(document.getElementById('paymentMethodId').value=${savedCreditCard.paymentMethodId});"><span>${uiLabelMap.DeleteLabel}</span></a>
  </div>
</li>