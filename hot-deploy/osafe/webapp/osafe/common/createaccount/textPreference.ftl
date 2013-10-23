<#include "component://osafe/webapp/osafe/includes/CommonMacros.ftl"/>
<#assign mandatory= request.getAttribute("attributeMandatory")!"N"/>
<div class="${request.getAttribute("attributeClass")!}">
    <#assign partyDBTextPref=partyTextPreference!""/>
        <#assign partyTextPref=parameters.PARTY_TEXT_PREFERENCE!partyDBTextPref!""/>
        <#assign partyTextPreferenceYes=""/>
        <#assign partyTextPreferenceNo="checked"/>
        <#if partyTextPref?has_content>
          <#if partyTextPref == "Y">
            <#assign partyTextPreferenceNo=""/>
            <#assign partyTextPreferenceYes="checked"/>
          <#else>
             <#assign partyTextPreferenceYes=""/>
             <#assign partyTextPreferenceNo="checked"/>
          </#if>
      </#if>
      <div class="entry userTxtPreferenceYes createAccount">
          <label for="PARTY_TEXT_PREFERENCE"><#if mandatory == "Y"><@required/></#if>${uiLabelMap.TextMessageNotificationsCaption}</label>
          <input type="radio" id="PARTY_TEXT_YES" name="PARTY_TEXT_PREFERENCE" value="Y" ${partyTextPreferenceYes!""}/><span class="radioOptionText">${uiLabelMap.RegistrationTextPreferenceYesLabel}</span>
      </div>
      <div class="entry userTxtPreferenceNo createAccount">
          <label>&nbsp;</label>
          <input type="radio" id="PARTY_TEXT_NO" name="PARTY_TEXT_PREFERENCE" value="N" ${partyTextPreferenceNo!""}/><span class="radioOptionText">${uiLabelMap.RegistrationTextPreferenceNoLabel}</span>
      </div>
      <@fieldErrors fieldName="PARTY_TEXT_PREFERENCE"/>
      <input type="hidden" id="PARTY_TEXT_PREFERENCE_MANDATORY" name="PARTY_TEXT_PREFERENCE_MANDATORY" value="${mandatory}"/>
</div>