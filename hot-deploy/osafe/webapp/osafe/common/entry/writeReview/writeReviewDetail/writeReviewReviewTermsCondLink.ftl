<#assign reviewTermsCondContent = delegator.findOne("Content", Static["org.ofbiz.base.util.UtilMisc"].toMap("contentId", "SP_REVIEW_TERMS_COND"), true) />
<#if ((reviewTermsCondContent.statusId)?if_exists == "CTNT_PUBLISHED")>
 <li class="${request.getAttribute("attributeClass")!}">
    <a name="reviewTermCondLink" href="javascript:displayDialogBox('reviewTermCond_');"><span>${uiLabelMap.TermsConditionsLabel}</span></a>
${screens.render("component://osafe/widget/DialogScreens.xml#reviewTermConditionDialog")}
 </li>
</#if>


