<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:output method="xml"/>
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
	
	<xsl:variable name="nodeunitcodevalue"><xsl:text>{nodes}</xsl:text></xsl:variable>

	<xsl:template match="/">

		<xsl:for-each select="patients/patient">
			<xsl:variable name="recordcount" select="position()"/>	<!-- need a numeric value for UID creation, which researchid is not always -->
			<xsl:variable name="researchid" select="researchid"/>
			<xsl:variable name="filename">patientxmlfiles/<xsl:value-of select="$researchid"/>.xml</xsl:variable>
			<xsl:choose>
				<!--<xsl:when test="not(doc-available($filename))">-->	<!-- does not work -->
				<xsl:when test="not(unparsed-text-available($filename))">
					<xsl:result-document method="xml" indent="yes" href="{$filename}">
						<xsl:variable name="dob"><xsl:value-of select="dobyear"/><xsl:value-of select="dobmonth"/>01</xsl:variable>		<!-- Use 01 because no day available -->
						
						<xsl:variable name="latestdate">
							<xsl:for-each select="
								  biopsy1date
								| biopsy2date
								| biopsy3date
								| biopsy4date
								| surgery1date
								| surgery2date
								| rt1startdate
								| rt1enddate
								| rt2startdate
								| rt2enddate
								| rt3startdate
								| rt3enddate
								| chemo1startdate
								| chemo1enddate
								| chemo2startdate
								| chemo2enddate
								| followupdate
								| dateofdeath
								| dateofrecurrence
								| dateof2ndprimary
								| priorpet1date
								| priorpet2date
								| priorpet3date
								| priorpet4date
								| postpet1date
								| postpet2date">
								<xsl:sort select="." data-type="text" order="descending"/>
<!--<xsl:message>checking <xsl:value-of select="."/></xsl:message>-->
								<xsl:if test="position() = 1">
<!--<xsl:message>have position 1 <xsl:value-of select="."/></xsl:message>-->
									<xsl:value-of select="replace(.,'[^0-9]','')"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
<!--<xsl:message>latestdate <xsl:value-of select="$latestdate"/></xsl:message>-->
<xsl:if test="string-length($latestdate) = 0">
<xsl:message>WARNING - latestdate missing</xsl:message>
</xsl:if>

						<xsl:variable name="heightinmetres">
							<xsl:if test="string(number(height)) != 'NaN'">
								<xsl:value-of select="format-number(number(height) div 100,'#.##')"/>		<!-- supplied in cm, need m ; need to format in case exceeds VR length sometimes -->
							</xsl:if>
						</xsl:variable>
<!--<xsl:message>height <xsl:value-of select="height"/> heightinmetres <xsl:value-of select="$heightinmetres"/></xsl:message>-->

						<xsl:variable name="patientid"><xsl:value-of select="$researchid"/></xsl:variable>
<!--<xsl:message>patientid <xsl:value-of select="$patientid"/></xsl:message>-->

<DicomStructuredReport>
  <DicomStructuredReportHeader>
  
    <SOPClassUID element="0016" group="0008" vr="UI">
      <value number="1">1.2.840.10008.5.1.4.1.1.88.33</value>
    </SOPClassUID>

    <StudyInstanceUID element="000d" group="0020" vr="UI">
      <value number="1">1.3.6.1.4.1.5962.1.2.0.1419869160.13176.<xsl:value-of select="$recordcount"/></value>
    </StudyInstanceUID>
    <SeriesInstanceUID element="000e" group="0020" vr="UI">
      <value number="1">1.3.6.1.4.1.5962.1.3.0.0.1419869160.13176.<xsl:value-of select="$recordcount"/></value>
    </SeriesInstanceUID>
    <SOPInstanceUID element="0018" group="0008" vr="UI">
      <value number="1">1.3.6.1.4.1.5962.1.1.0.0.0.1419869160.13176<xsl:value-of select="$recordcount"/></value>
    </SOPInstanceUID>

    <PatientName element="0010" group="0010" vr="PN">
      <value number="1"><xsl:value-of select="$patientid"/></value>
    </PatientName>
    <PatientID element="0020" group="0010" vr="LO">
      <value number="1"><xsl:value-of select="$patientid"/></value>
    </PatientID>
    <PatientBirthDate element="0030" group="0010" vr="DA">
      <value number="1"><xsl:value-of select="$dob"/></value>
    </PatientBirthDate>
    <PatientSex element="0040" group="0010" vr="CS">
      <value number="1"><xsl:value-of select="gender"/></value>
    </PatientSex>
    <PatientSize element="1020" group="0010" vr="DS">
      <value number="1"><xsl:value-of select="$heightinmetres"/></value>
    </PatientSize>
    <PatientWeight element="1030" group="0010" vr="DS">
      <value number="1"><xsl:value-of select="weight"/></value>
    </PatientWeight>

    <StudyDate element="0020" group="0008" vr="DA">
      <value number="1"><xsl:value-of select="$latestdate"/></value>		<!-- Use DOB because no other date any more or less relevant or always available -->
    </StudyDate>
    <StudyTime element="0030" group="0008" vr="TM">
      <value number="1">000000</value>
    </StudyTime>
    <ReferringPhysicianName element="0090" group="0008" vr="PN" />
    <StudyID element="0010" group="0020" vr="SH">
      <value number="1"><xsl:value-of select="$latestdate"/></value>		<!-- Use DOB because no other date any more or less relevant or always available -->
    </StudyID>
    <AccessionNumber element="0050" group="0008" vr="SH" />
    <StudyDescription element="1030" group="0008" vr="LO">
      <value number="1">Clinical Data</value>
    </StudyDescription>

    <Modality element="0060" group="0008" vr="CS">
      <value number="1">SR</value>
    </Modality>
    <SeriesNumber element="0011" group="0020" vr="IS">
      <value number="1">1</value>
    </SeriesNumber>
    <SeriesDate element="0021" group="0008" vr="DA">
      <value number="1"><xsl:value-of select="$latestdate"/></value>
    </SeriesDate>
    <SeriesTime element="0031" group="0008" vr="TM">
      <value number="1">000000</value>
    </SeriesTime>
    <SeriesDescription element="103E" group="0008" vr="LO">
      <value number="1">Clinical Data</value>
    </SeriesDescription>
    <ReferencedPerformedProcedureStepSequence element="1111" group="0008" vr="SQ" />

	<Manufacturer element="0070" group="0008" vr="LO">
      <value number="1">PixelMed</value>
    </Manufacturer>
    <InstitutionName element="0080" group="0008" vr="LO">
      <value number="1">University of Iowa</value>
    </InstitutionName>
    <StationName element="1010" group="0008" vr="SH">
      <value number="1">NONE</value>
    </StationName>
    <ManufacturerModelName element="1090" group="0008" vr="LO">
      <value number="1">XSLT from clinical database extract</value>
    </ManufacturerModelName>
    <DeviceSerialNumber element="1000" group="0018" vr="LO">
      <value number="1">78658246582465</value>
    </DeviceSerialNumber>
    <SoftwareVersions element="1020" group="0018" vr="LO">
      <value number="1">0.1</value>
    </SoftwareVersions>

    <InstanceNumber element="0013" group="0020" vr="IS">
      <value number="1">1</value>
    </InstanceNumber>
    <CompletionFlag element="a491" group="0040" vr="CS">
      <value number="1">COMPLETE</value>
    </CompletionFlag>
    <VerificationFlag element="a493" group="0040" vr="CS">
      <value number="1">UNVERIFIED</value>
    </VerificationFlag>	
    <ContentDate element="0023" group="0008" vr="DA">
      <value number="1"><xsl:value-of select="$latestdate"/></value>
    </ContentDate>
    <ContentTime element="0033" group="0008" vr="TM">
      <value number="1">000000</value>
    </ContentTime>
    <PerformedProcedureCodeSequence element="a372" group="0040" vr="SQ" />

	</DicomStructuredReportHeader>
  <DicomStructuredReportContent>
    <container continuity="SEPARATE" sopclass="1.2.840.10008.5.1.4.1.1.88.33" template="QIICR_2000" templatemappingresource="99QIICR">
	
      <concept cm="Summary Clinical Document" csd="SRT" cv="R-42BAB" />			<!-- probably need a better title code (SNOMED children are discharge or transfer report) -->

      <code relationship="HAS CONCEPT MOD">
        <concept cm="Language of Content Item and Descendants" csd="DCM" cv="121049" />
        <value cm="English" csd="RFC3066" cv="eng" />
        <code relationship="HAS CONCEPT MOD">
          <concept cm="Country of Language" csd="DCM" cv="121046" />
          <value cm="United States" csd="ISO3166_1" cv="US" />
        </code>
      </code>
	  
      <container continuity="SEPARATE" relationship="CONTAINS">				<!-- subset of TID 3602 Cardiovascular Patient Characteristics -->
        <concept cm="Patient Characteristics" csd="DCM" cv="121118" />
		
		<!-- ? should calculate age from DOB and ? what other date ? (121033, DCM, "Subject Age") -->
		
<xsl:if test="string-length($dob) != 0">
            <date relationship="CONTAINS">	<!-- not in TID 3602; from TID 1007 Subject Context, Patient -->
		      <concept cm="Subject Birth Date" csd="DCM" cv="121031" />
			  <value><xsl:value-of select="$dob"/></value>
		    </date>
</xsl:if>

<xsl:variable name="gender" select="replace(normalize-space(lower-case(gender)),'[^a-z]','')"/>
<xsl:if test="string-length($gender) != 0">	<!-- M, F -->
          <code relationship="CONTAINS">
            <concept cm="Subject Sex" csd="DCM" cv="121032" />		<!-- from CID 7455 Sex -->
<xsl:choose>
<xsl:when test="$gender = 'm'">
            <value cm="Male" csd="DCM" cv="M" />
</xsl:when>
<xsl:when test="$gender = 'f'">
            <value cm="Female" csd="DCM" cv="F" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized gender <xsl:value-of select="$gender"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
          </code>
</xsl:if>

<xsl:variable name="height"   select="replace(normalize-space(lower-case(height)),'[^0-9.]','')"/>
<xsl:if test="string-length($height) != 0">
            <num relationship="CONTAINS">
		      <concept cm="Patient Height" csd="LN" cv="8302-2" />
			  <value><xsl:value-of select="$height"/></value>
			  <units cm="cm" csd="UCUM" cv="cm" />
		    </num>
</xsl:if>

<xsl:variable name="weight"   select="replace(normalize-space(lower-case(weight)),'[^0-9.]','')"/>
<xsl:if test="string-length($weight) != 0">
            <num relationship="CONTAINS">
		      <concept cm="Patient Weight" csd="LN" cv="29463-7" />
			  <value><xsl:value-of select="$weight"/></value>
			  <units cm="kg" csd="UCUM" cv="kg" />
		    </num>
</xsl:if>

<xsl:variable name="race"   select="replace(normalize-space(lower-case(race)),'[^a-z]','')"/>		<!-- not in TID 3602 -->
<xsl:if test="string-length($race) != 0 and not(matches($race,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Racial group" csd="SRT" cv="S-0004D" />
<xsl:choose>
<xsl:when test="$race = 'african'">
            <value cm="African race" csd="SRT" cv="S-0004E" />
</xsl:when>
<xsl:when test="$race = 'asian'">
            <value cm="Asian race" csd="SRT" cv="S-00051" />
</xsl:when>
<xsl:when test="$race = 'caucasian'">
            <value cm="Caucasian race" csd="SRT" cv="S-0003D" />
</xsl:when>
<xsl:when test="$race = 'nativeamerican'">
            <value cm="American Indian race" csd="SRT" cv="S-0004F" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized race <xsl:value-of select="$race"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="spanishorigin"   select="replace(normalize-space(lower-case(spanishorigin)),'[^a-z]','')"/>		<!-- not in TID 3602 -->
<xsl:if test="string-length($spanishorigin) != 0 and not(matches($spanishorigin,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Hispanic" csd="SRT" cv="S-00045" />
<xsl:choose>
<xsl:when test="$spanishorigin = 'yes'">
            <value cm="Yes" csd="SRT" cv="R-0038D" />
</xsl:when>
<xsl:when test="$spanishorigin = 'no'">
            <value cm="No" csd="SRT" cv="R-00339" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized spanishorigin <xsl:value-of select="$spanishorigin"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

      </container>




      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Problem List" csd="LN" cv="11450-4" />

<xsl:variable name="diabetes" select="replace(normalize-space(lower-case(diabetes)),'[^a-z]','')"/>
<!--<xsl:message>diabetes |<xsl:value-of select="diabetes"/>| cleaned is |<xsl:value-of select="$diabetes"/>|</xsl:message>-->
<xsl:if test="$diabetes != 'no'">	<!-- No, Insulin-Dependent, Non Insulin-Dependent, Diet-Controlled -->
<!--<xsl:message>diabetes is not no</xsl:message>-->

        <container continuity="SEPARATE" relationship="CONTAINS">	<!-- DTID 3829 Problem Properties -->
          <concept cm="Concern" csd="DCM" cv="121430" />
		  	
          <code relationship="CONTAINS">
            <concept cm="Problem" csd="SRT" cv="F-01000" />			<!-- from CID 3769 Concern Types -->
            <value cm="History of Diabetes mellitus" csd="SRT" cv="G-023F" />
          </code>
          <code relationship="CONTAINS">
            <concept cm="Therapy" csd="SRT" cv="P0-0000E" />		<!-- from CID 3722 Diabetic Therapy -->
<xsl:choose>
<xsl:when test="$diabetes = 'dietcontrolled'">
<!--<xsl:message>diabetes is dietcontrolled</xsl:message>-->
            <value cm="Diabetic on Dietary Treatment" csd="SRT" cv="F-02F14" />
</xsl:when>
<xsl:when test="$diabetes = 'noninsulindependent'">
<!--<xsl:message>diabetes is noninsulindependent</xsl:message>-->
            <value cm="Diabetic on Oral Treatment" csd="SRT" cv="F-02F15" />
</xsl:when>
<xsl:when test="$diabetes = 'insulindependent'">
<!--<xsl:message>diabetes is insulindependent</xsl:message>-->
            <value cm="Diabetic on Insulin" csd="SRT" cv="F-02F16" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized diabetes <xsl:value-of select="$diabetes"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
          </code>
        </container>
</xsl:if>
      </container>
	  
      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Social History" csd="LN" cv="29762-2" />
		
<xsl:variable name="smoker" select="replace(normalize-space(lower-case(smoker)),'[^a-z]','')"/>
<xsl:if test="$smoker != 'unknown'">	<!-- Yes, Former, No, Unknown -->
<!--<xsl:message>smoker is not unknown</xsl:message>-->

		<code relationship="CONTAINS">
          <concept cm="Tobacco Smoking Behavior" csd="SRT" cv="F-93109" />			<!-- from TID 3802 Row 15, values from CID 3724 Smoking History -->
<xsl:choose>
<xsl:when test="$smoker = 'yes'">
<!--<xsl:message>smoker is yes</xsl:message>-->
            <value cm="Current Smoker" csd="SRT" cv="S-32000" />
</xsl:when>
<xsl:when test="$smoker = 'former'">
<!--<xsl:message>smoker is former</xsl:message>-->
            <value cm="Former Smoker" csd="SRT" cv="S-32070" />
</xsl:when>
<xsl:when test="$smoker = 'no'">
<!--<xsl:message>smoker is no</xsl:message>-->
            <value cm="No History of Smoking" csd="SRT" cv="F-9321F" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized smoker <xsl:value-of select="$smoker"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="drinker" select="replace(normalize-space(lower-case(drinker)),'[^a-z]','')"/>
<xsl:if test="$drinker != 'unknown'">	<!-- Significant, Social, No, Unknown -->
<!--<xsl:message>drinker is not unknown</xsl:message>-->

		<code relationship="CONTAINS">
          <concept cm="Alcohol consumption" csd="SRT" cv="F-02573" />	<!-- TID 3802 Row 14 has this as one of the concepts for a TEXT value; we use a CODE instead -->
<xsl:choose>
<xsl:when test="$drinker = 'significant'">
<!--<xsl:message>drinker is significant</xsl:message>-->
            <value cm="Alcohol intake above recommended sensible limits" csd="SRT" cv="F-60018" />
</xsl:when>
<xsl:when test="$drinker = 'social'">
<!--<xsl:message>drinker is social</xsl:message>-->
            <value cm="Alcohol intake within recommended sensible limits" csd="SRT" cv="F-60019" />
</xsl:when>
<xsl:when test="$drinker = 'no'">
<!--<xsl:message>drinker is no</xsl:message>-->
            <value cm="None" csd="SRT" cv="R-40775" />	<!-- not sure if this generic concept is right :( -->
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized drinker <xsl:value-of select="$drinker"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="chewingtobacco" select="replace(normalize-space(lower-case(chewingtobacco)),'[^a-z]','')"/>
<xsl:if test="$chewingtobacco != 'unknown'">	<!-- Yes, Former, No, Unknown -->
<!--<xsl:message>chewingtobacco is not unknown</xsl:message>-->

		<code relationship="CONTAINS">
          <concept cm="Details of tobacco chewing" csd="SRT" cv="F-0434C" />			<!-- nothing in DICOM yet, except as (C-F3310, SRT, "Chewing tobacco") in CID 6089 Substances invoked in DTID 9002 “Medication, Substance, Environmental Exposure” in TID 9007 General Relevant Patient Information -->
<xsl:choose>
<xsl:when test="$chewingtobacco = 'yes'">
<!--<xsl:message>chewingtobacco is yes</xsl:message>-->
            <value cm="Chews tobacco" csd="SRT" cv="S-32060" />
</xsl:when>
<xsl:when test="$chewingtobacco = 'former'">
<!--<xsl:message>chewingtobacco is former</xsl:message>-->
            <value cm="Ex-tobacco chewer" csd="SRT" cv="F-9321B" />
</xsl:when>
<xsl:when test="$chewingtobacco = 'no'">
<!--<xsl:message>chewingtobacco is no</xsl:message>-->
            <value cm="Does not chew tobacco" csd="SRT" cv="F-93219" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized chewingtobacco <xsl:value-of select="$chewingtobacco"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

      </container>
	  
      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Tumor Staging" csd="SRT" cv="G-E395" />

<xsl:variable name="finalsite" select="replace(normalize-space(lower-case(finalsite)),'[^a-z]','')"/>
<xsl:if test="string-length($finalsite) != 0">
		<code relationship="CONTAINS">
          <concept cm="Primary tumor site" csd="SRT" cv="R-100D9" />
<xsl:choose>
<xsl:when test="$finalsite = 'baseoftongue'">
            <value cm="base of tongue" csd="SRT" cv="T-53131" />
</xsl:when>
<xsl:when test="$finalsite = 'buccalmucosa'">
            <value cm="buccal mucosa" csd="SRT" cv="T-51305" />
</xsl:when>
<xsl:when test="$finalsite = 'floorofmouth'">
            <value cm="floor of mouth" csd="SRT" cv="T-51200" />
</xsl:when>
<xsl:when test="$finalsite = 'glottis'">
            <value cm="glottis" csd="SRT" cv="T-24440" />
</xsl:when>
<xsl:when test="$finalsite = 'hypopharynx'">
            <value cm="hypopharynx" csd="SRT" cv="T-55300" />
</xsl:when>
<xsl:when test="$finalsite = 'larynx'">
            <value cm="larynx" csd="SRT" cv="T-24100" />
</xsl:when>
<xsl:when test="$finalsite = 'lip'">
            <value cm="lip" csd="SRT" cv="T-52000" />
</xsl:when>
<xsl:when test="$finalsite = 'loweralveolarridge'">
            <value cm="lower alveolar ridge" csd="SRT" cv="T-D07CB" />
</xsl:when>
<xsl:when test="$finalsite = 'maxillarysinus'">
            <value cm="maxillary sinus" csd="SRT" cv="T-22100" />
</xsl:when>
<xsl:when test="$finalsite = 'nasalcavity'">
            <value cm="nasal cavity" csd="SRT" cv="T-21301" />
</xsl:when>
<xsl:when test="$finalsite = 'nasopharynx'">
            <value cm="nasopharynx" csd="SRT" cv="T-23000" />
</xsl:when>
<xsl:when test="$finalsite = 'oralcavity'">
            <value cm="oral cavity" csd="SRT" cv="T-51004" />
</xsl:when>
<xsl:when test="$finalsite = 'oraltongue'">
            <value cm="tongue" csd="SRT" cv="T-53000" />
</xsl:when>
<xsl:when test="$finalsite = 'oropharynx'">
            <value cm="oropharynx" csd="SRT" cv="T-55200" />
</xsl:when>
<xsl:when test="$finalsite = 'paranasalsinus'">
            <value cm="paranasal sinus" csd="SRT" cv="T-22000" />
</xsl:when>
<xsl:when test="$finalsite = 'pharyngealtonsils'">
            <value cm="pharyngeal tonsil (adenoid)" csd="SRT" cv="T-C5300" />
</xsl:when>
<xsl:when test="$finalsite = 'pyriformsinus'">
            <value cm="pyriform sinus" csd="SRT" cv="T-55320" />
</xsl:when>
<xsl:when test="$finalsite = 'retromolartrigone'">
            <value cm="retromolar trigone" csd="SRT" cv="T-51600" />
</xsl:when>
<xsl:when test="$finalsite = 'salivarygland'">
            <value cm="salivary gland" csd="SRT" cv="T-61007" />
</xsl:when>
<xsl:when test="$finalsite = 'supraglottis'">
            <value cm="supraglottis" csd="SRT" cv="T-24454" />
</xsl:when>
<xsl:when test="$finalsite = 'tonsil'">
            <!-- <value cm="Palatine tonsil" csd="SRT" cv="T-C5100" /> -->
            <value cm="tonsil and adenoid" csd="SRT" cv="T-C5001" />
</xsl:when>
<xsl:when test="$finalsite = 'unknownprimary'">
            <value cm="unknown primary neoplasia site" csd="UMLS" cv="C0221297" />
</xsl:when>
<xsl:when test="$finalsite = 'uvula'">
            <value cm="palatine uvula" csd="SRT" cv="T-51130" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized finalsite <xsl:value-of select="$finalsite"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="finalstage" select="replace(normalize-space(lower-case(finalstage)),'[^a-z0-9]','')"/>
<xsl:if test="string-length($finalstage) != 0 and not(contains($finalstage,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Tumor stage finding" csd="SRT" cv="R-00443" />
<xsl:choose>
<xsl:when test="$finalstage = '1'">
            <value cm="Clinical Stage I" csd="SRT" cv="G-E100" />
</xsl:when>
<xsl:when test="$finalstage = '2'">
            <value cm="Clinical Stage II" csd="SRT" cv="G-E200" />
</xsl:when>
<xsl:when test="$finalstage = '3'">
            <value cm="Clinical Stage III" csd="SRT" cv="G-E300" />
</xsl:when>
<xsl:when test="$finalstage = '4'">
            <value cm="Clinical Stage IV" csd="SRT" cv="G-E400" />
</xsl:when>
<xsl:when test="$finalstage = '4a'">
            <value cm="Clinical Stage IV A" csd="SRT" cv="G-E410" />
</xsl:when>
<xsl:when test="$finalstage = '4b'">
            <value cm="Clinical Stage IV B" csd="SRT" cv="G-E420" />
</xsl:when>
<xsl:when test="$finalstage = '4c'">
            <value cm="Clinical Stage IV C" csd="SRT" cv="G-E430" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized finalstage <xsl:value-of select="$finalsite"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="finalt" select="replace(normalize-space(lower-case(finalt)),'[^a-z0-9]','')"/>
<xsl:variable name="finaln" select="replace(normalize-space(lower-case(finaln)),'[^a-z0-9]','')"/>
<xsl:variable name="finalm" select="replace(normalize-space(lower-case(finalm)),'[^a-z0-9]','')"/>
<xsl:if test="(string-length($finalt) != 0 and not(contains($finalt,'unknown'))) or (string-length($finaln) != 0 and not(contains($finaln,'unknown'))) or (string-length($finalm) != 0 and not(contains($finalm,'unknown')))">
        <container continuity="SEPARATE" relationship="CONTAINS">
          <concept cm="TNM Category" csd="SRT" cv="F-005C4" />

<xsl:if test="(string-length($finalt) != 0 and not(contains($finalt,'unknown')))">
		<code relationship="CONTAINS">
          <concept cm="T Stage" csd="SRT" cv="G-F150" />
<xsl:choose>
<xsl:when test="$finalt = '0'">
            <value cm="Tumor Stage T0" csd="SRT" cv="G-F152" />
</xsl:when>
<xsl:when test="$finalt = '1'">
            <value cm="Tumor Stage T1" csd="SRT" cv="G-F153" />
</xsl:when>
<xsl:when test="$finalt = '1a'">
            <value cm="Tumor Stage T1a" csd="SRT" cv="G-F158" />
</xsl:when>
<xsl:when test="$finalt = '1b'">
            <value cm="Tumor Stage T1b" csd="SRT" cv="G-F15B" />
</xsl:when>
<xsl:when test="$finalt = '2'">
            <value cm="Tumor Stage T2" csd="SRT" cv="G-F154" />
</xsl:when>
<xsl:when test="$finalt = '2a'">
            <value cm="Tumor Stage T2a" csd="SRT" cv="G-F15D" />
</xsl:when>
<xsl:when test="$finalt = '2b'">
            <value cm="Tumor Stage T2b" csd="SRT" cv="G-F15E" />
</xsl:when>
<xsl:when test="$finalt = '3'">
            <value cm="Tumor Stage T3" csd="SRT" cv="G-F155" />
</xsl:when>
<xsl:when test="$finalt = '3a'">
            <value cm="Tumor Stage T3a" csd="SRT" cv="G-F16D" />
</xsl:when>
<xsl:when test="$finalt = '3b'">
            <value cm="Tumor Stage T3b" csd="SRT" cv="G-F16E" />
</xsl:when>
<xsl:when test="$finalt = '4'">
            <value cm="Tumor Stage T4" csd="SRT" cv="G-F156" />
</xsl:when>
<xsl:when test="$finalt = '4a'">
            <value cm="Tumor Stage T4a" csd="SRT" cv="G-F176" />
</xsl:when>
<xsl:when test="$finalt = '4b'">
            <value cm="Tumor Stage T4b" csd="SRT" cv="G-F177" />
</xsl:when>
<xsl:when test="$finalt = 'x'">
            <value cm="Tumor Stage TX" csd="SRT" cv="G-F157" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized finalt <xsl:value-of select="$finalt"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:if test="(string-length($finaln) != 0 and not(contains($finaln,'unknown')))">
		<code relationship="CONTAINS">
          <concept cm="N Stage" csd="SRT" cv="R-40030" />
<xsl:choose>
<xsl:when test="finaln = '0'">
            <value cm="Node Stage N0" csd="SRT" cv="G-F160" />
</xsl:when>
<xsl:when test="finaln = '1'">
            <value cm="Node Stage N1" csd="SRT" cv="G-F161" />
</xsl:when>
<xsl:when test="finaln = '1a'">
            <value cm="Node Stage N1a" csd="SRT" cv="G-F166" />
</xsl:when>
<xsl:when test="finaln = '1b'">
            <value cm="Node Stage N1b" csd="SRT" cv="G-F167" />
</xsl:when>
<xsl:when test="finaln = '2'">
            <value cm="Node Stage N2" csd="SRT" cv="G-F162" />
</xsl:when>
<xsl:when test="finaln = '2a'">
            <value cm="Node Stage N2a" csd="SRT" cv="G-F17E" />
</xsl:when>
<xsl:when test="finaln = '2b'">
            <value cm="Node Stage N2b" csd="SRT" cv="G-F17F" />
</xsl:when>
<xsl:when test="finaln = '2c'">
            <value cm="Node Stage N2c" csd="SRT" cv="G-F188" />
</xsl:when>
<xsl:when test="finaln = '3'">
            <value cm="Node Stage N3" csd="SRT" cv="G-F163" />
</xsl:when>
<xsl:when test="finaln = 'x'">
            <value cm="Node Stage NX" csd="SRT" cv="G-F165" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized finaln <xsl:value-of select="$finalt"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:if test="(string-length($finalm) != 0 and not(contains($finalm,'unknown')))">
		<code relationship="CONTAINS">
          <concept cm="M Stage" csd="SRT" cv="R-40031" />
<xsl:choose>
<xsl:when test="finalm = '0'">
            <value cm="Metastasis Stage M0" csd="SRT" cv="G-F170" />
</xsl:when>
<xsl:when test="finalm = '1'">
            <value cm="Metastasis Stage M1" csd="SRT" cv="G-F171" />
</xsl:when>
<xsl:when test="finalm = 'X'">
            <value cm="Metastasis Stage MX" csd="SRT" cv="G-F175" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized finalm <xsl:value-of select="$finalt"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

        </container>
</xsl:if>
      </container>

      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Past medical history" csd="SRT" cv="G-03E7" />		<!-- plural would be nice for section heading :( -->
		
<xsl:variable name="previousradiation" select="replace(normalize-space(lower-case(previousradiation)),'[^a-z]','')"/>
<xsl:if test="string-length($previousradiation) != 0">	<!-- Yes, No -->
		<code relationship="CONTAINS">
          <concept cm="History of radiation therapy" csd="SRT" cv="P0-099EB" />
<xsl:choose>
<xsl:when test="$previousradiation = 'yes'">
            <value cm="Performed" csd="SRT" cv="R-42514" />
</xsl:when>
<xsl:when test="$previousradiation = 'no'">
            <value cm="Not performed" csd="SRT" cv="R-4135B" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized previousradiation <xsl:value-of select="$previousradiation"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>
		
<xsl:variable name="priormalignancies" select="replace(normalize-space(lower-case(priormalignancies)),'[^a-z]','')"/>
<xsl:if test="string-length($priormalignancies) != 0">	<!-- Yes, No -->
		<code relationship="CONTAINS">
          <concept cm="History of malignant neoplasm" csd="SRT" cv="G-0133" />
<xsl:choose>
<xsl:when test="$priormalignancies = 'priorhnca'">
            <value cm="History of malignant neoplasm of head and/or neck" csd="SRT" cv="G-0529" />
</xsl:when>
<xsl:when test="$priormalignancies = 'priorotherca'">
            <value cm="History of malignant neoplasm" csd="SRT" cv="G-0133" />		<!-- this is not "other" code, just more general -  but results in G-0133 = G-0133 ! :( -->
</xsl:when>
<xsl:when test="$priormalignancies = 'no'">
            <value cm="No history of malignant neoplastic disease" csd="SRT" cv="R-FB75F" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized priormalignancies <xsl:value-of select="$priormalignancies"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>
      </container>

      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Diagnostic Procedure" csd="SRT" cv="P0-00002" />		<!-- plural would be nice for section heading :( -->

<xsl:call-template name="biopsy">
	<xsl:with-param name="biopsydateparam"     select="biopsy1date"/>
	<xsl:with-param name="biopsylocationparam" select="biopsy1location"/>
</xsl:call-template>

<xsl:call-template name="biopsy">
	<xsl:with-param name="biopsydateparam"     select="biopsy2date"/>
	<xsl:with-param name="biopsylocationparam" select="biopsy2location"/>
</xsl:call-template>

<xsl:call-template name="biopsy">
	<xsl:with-param name="biopsydateparam"     select="biopsy3date"/>
	<xsl:with-param name="biopsylocationparam" select="biopsy3location"/>
</xsl:call-template>

<xsl:call-template name="biopsy">
	<xsl:with-param name="biopsydateparam"     select="biopsy4date"/>
	<xsl:with-param name="biopsylocationparam" select="biopsy4location"/>
</xsl:call-template>

      </container>

      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Therapeutic Procedure" csd="SRT" cv="P0-0000E" />		<!-- plural would be nice for section heading :( -->
		
<xsl:call-template name="surgery">
	<xsl:with-param name="surgerydateparam"             select="surgery1date"/>
	<xsl:with-param name="surgerydescparam"             select="surgery1desc"/>
	<xsl:with-param name="surgeryprimaryressectedparam" select="surgery1primaryressected"/>
	<xsl:with-param name="surgerynodedissectionparam"   select="surgery1nodedissection"/>
</xsl:call-template>
		
<xsl:call-template name="surgery">
	<xsl:with-param name="surgerydateparam"             select="surgery2date"/>
	<xsl:with-param name="surgerydescparam"             select="surgery2desc"/>
	<xsl:with-param name="surgeryprimaryressectedparam" select="surgery2primaryressected"/>
	<xsl:with-param name="surgerynodedissectionparam"   select="surgery2nodedissection"/>
</xsl:call-template>
		
<xsl:call-template name="radiotherapy">
	<xsl:with-param name="rtstartdateparam"       select="rt1startdate"/>
	<xsl:with-param name="rtenddateparam"         select="rt1enddate"/>
	<xsl:with-param name="rtdoseparam"            select="rt1"/>
	<xsl:with-param name="rtdoseperfractionparam" select="rt1doseperfraction"/>
	<xsl:with-param name="rtnotesparam"           select="rt1notes"/>
</xsl:call-template>
		
<xsl:call-template name="radiotherapy">
	<xsl:with-param name="rtstartdateparam"       select="rt2startdate"/>
	<xsl:with-param name="rtenddateparam"         select="rt2enddate"/>
	<xsl:with-param name="rtdoseparam"            select="rt2"/>
	<xsl:with-param name="rtdoseperfractionparam" select="rt2doseperfraction"/>
	<xsl:with-param name="rtnotesparam"           select="rt2notes"/>
</xsl:call-template>
		
<xsl:call-template name="radiotherapy">
	<xsl:with-param name="rtstartdateparam"       select="rt3startdate"/>
	<xsl:with-param name="rtenddateparam"         select="rt3enddate"/>
	<xsl:with-param name="rtdoseparam"            select="rt3"/>
	<xsl:with-param name="rtdoseperfractionparam" select="rt3doseperfraction"/>
	<xsl:with-param name="rtnotesparam"           select="rt3notes"/>
</xsl:call-template>
		
<xsl:call-template name="chemotherapy">
	<xsl:with-param name="chemostartdateparam" select="chemo1startdate"/>
	<xsl:with-param name="chemoenddateparam"   select="chemo1enddate"/>
	<xsl:with-param name="chemodrug1param"     select="chemo1drug1"/>
	<xsl:with-param name="chemodrug2param"     select="chemo1drug2"/>
	<xsl:with-param name="chemodrug3param"     select="chemo1drug3"/>
</xsl:call-template>
		
<xsl:call-template name="chemotherapy">
	<xsl:with-param name="chemostartdateparam" select="chemo2startdate"/>
	<xsl:with-param name="chemoenddateparam"   select="chemo2enddate"/>
	<xsl:with-param name="chemodrug1param"     select="chemo2drug1"/>
	<xsl:with-param name="chemodrug2param"     select="chemo2drug2"/>
	<xsl:with-param name="chemodrug3param"     select="chemo2drug3"/>
</xsl:call-template>

      </container>

      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Pathology of original tumor" csd="99PMP" cv="300015" />
		
		<xsl:call-template name="pathology">
			<xsl:with-param name="diffparam"    select="primarydiff"/>
			<xsl:with-param name="marginsparam" select="primarymargins"/>
			<xsl:with-param name="pniparam"     select="primarypni"/>
			<xsl:with-param name="iviparam"     select="primaryivi"/>
		</xsl:call-template>
	
        <container continuity="SEPARATE" relationship="CONTAINS">
          <concept cm="Excision of cervical lymph nodes group" csd="SRT" cv="P1-65320" />

<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'1'"/>
	<xsl:with-param name="levelsideparam" select="'ipsi'"/>
	<xsl:with-param name="countparam"     select="ipsilevel1"/>
	<xsl:with-param name="removedparam"   select="ipsilevel1total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'2'"/>
	<xsl:with-param name="levelsideparam" select="'ipsi'"/>
	<xsl:with-param name="countparam"     select="ipsilevel2"/>
	<xsl:with-param name="removedparam"   select="ipsilevel2total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'3'"/>
	<xsl:with-param name="levelsideparam" select="'ipsi'"/>
	<xsl:with-param name="countparam"     select="ipsilevel3"/>
	<xsl:with-param name="removedparam"   select="ipsilevel3total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'4'"/>
	<xsl:with-param name="levelsideparam" select="'ipsi'"/>
	<xsl:with-param name="countparam"     select="ipsilevel4"/>
	<xsl:with-param name="removedparam"   select="ipsilevel4total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'5'"/>
	<xsl:with-param name="levelsideparam" select="'ipsi'"/>
	<xsl:with-param name="countparam"     select="ipsilevel5"/>
	<xsl:with-param name="removedparam"   select="ipsilevel5total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'other'"/>
	<xsl:with-param name="levelsideparam" select="'ipsi'"/>
	<xsl:with-param name="countparam"     select="ipsiother"/>
	<xsl:with-param name="removedparam"   select="ipsiothertotal"/>
</xsl:call-template>

<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'1'"/>
	<xsl:with-param name="levelsideparam" select="'contra'"/>
	<xsl:with-param name="countparam"     select="contralevel1"/>
	<xsl:with-param name="removedparam"   select="contralevel1total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'2'"/>
	<xsl:with-param name="levelsideparam" select="'contra'"/>
	<xsl:with-param name="countparam"     select="contralevel2"/>
	<xsl:with-param name="removedparam"   select="contralevel2total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'3'"/>
	<xsl:with-param name="levelsideparam" select="'contra'"/>
	<xsl:with-param name="countparam"     select="contralevel3"/>
	<xsl:with-param name="removedparam"   select="contralevel3total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'4'"/>
	<xsl:with-param name="levelsideparam" select="'contra'"/>
	<xsl:with-param name="countparam"     select="contralevel4"/>
	<xsl:with-param name="removedparam"   select="contralevel4total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'5'"/>
	<xsl:with-param name="levelsideparam" select="'contra'"/>
	<xsl:with-param name="countparam"     select="contralevel5"/>
	<xsl:with-param name="removedparam"   select="contralevel5total"/>
</xsl:call-template>
<xsl:call-template name="nodegroup">
	<xsl:with-param name="levelparam"     select="'other'"/>
	<xsl:with-param name="levelsideparam" select="'contra'"/>
	<xsl:with-param name="countparam"     select="contraother"/>
	<xsl:with-param name="removedparam"   select="contraothertotal"/>
</xsl:call-template>

<xsl:variable name="extracapsularextension" select="replace(normalize-space(lower-case(extracapsularextension)),'[^a-z]','')"/>
<xsl:if test="string-length($extracapsularextension) != 0 and not(matches($extracapsularextension,'unknown'))">
            <code relationship="CONTAINS">
              <concept cm="Status of extra-capsular extension of nodal tumor" csd="SRT" cv="F-004ED" />
<xsl:choose>
<xsl:when test="$extracapsularextension = 'yes'">
            <value cm="Extra-capsular extension of nodal tumor present" csd="SRT" cv="F-004F1" />
</xsl:when>
<xsl:when test="$extracapsularextension = 'no'">
            <value cm="Extra-capsular extension of nodal tumor absent" csd="SRT" cv="F-004EF" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized extracapsularextension <xsl:value-of select="$extracapsularextension"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
            </code>
</xsl:if>	<!-- extracapsularextension -->

<xsl:variable name="otherdescription" select="replace(normalize-space(lower-case(otherdescription)),'[^a-zA-Z0-9 /,()-]','')"/>
<xsl:if test="string-length($otherdescription) != 0">
            <text relationship="CONTAINS">
              <concept cm="Comment" csd="DCM" cv="121106" />
			  <value><xsl:value-of select="$otherdescription"/></value>
            </text>
</xsl:if>	<!-- otherdescription -->

        </container>
      </container>

      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Disease Outcome" csd="UMLS" cv="C0679250"/>
		
		
<xsl:variable name="followupdate" select="replace(normalize-space(lower-case(followupdate)),'[^0-9]','')"/>
<xsl:if test="string-length($followupdate) != 0">
		<date relationship="CONTAINS">
          <concept cm="Follow-up visit date" csd="UMLS" cv="C3694716" />
          <value><xsl:value-of select="$followupdate"/></value>
		</date>
</xsl:if>

<xsl:variable name="followupstatus" select="replace(normalize-space(lower-case(followupstatus)),'[^a-z]','')"/>
<xsl:if test="string-length($followupstatus) != 0 and not(matches($followupstatus,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Followup status" csd="SRT" cv="F-00F54"/>
<xsl:choose>
<xsl:when test="$followupstatus = 'ned'">
            <value cm="No evidence of disease" csd="UMLS" cv="C1518340" />
</xsl:when>
<xsl:when test="$followupstatus = 'localdisease'">
            <value cm="Local disease" csd="SRT" cv="DF-00280" />
</xsl:when>
<xsl:when test="$followupstatus = 'distantdisease'">
            <value cm="Distant metastases" csd="UMLS" cv="C3641061" />
</xsl:when>
<xsl:when test="$followupstatus = 'localdistant'">
            <value cm="Local disease and distant metastases" csd="99PMP" cv="300010" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized followupstatus <xsl:value-of select="$followupstatus"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="dateofdeath" select="replace(normalize-space(lower-case(dateofdeath)),'[^0-9]','')"/>
<xsl:if test="string-length($dateofdeath) != 0">
		<date relationship="CONTAINS">
          <concept cm="Date of death" csd="SRT" cv="F-04922" />
          <value><xsl:value-of select="$dateofdeath"/></value>
		</date>
</xsl:if>

<xsl:variable name="causeofdeath" select="replace(normalize-space(lower-case(causeofdeath)),'[^a-z]','')"/>
<xsl:if test="string-length($causeofdeath) != 0 and not(matches($causeofdeath,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Cause of death" csd="SRT" cv="F-03E6D"/>
<xsl:choose>
<xsl:when test="$causeofdeath = 'complication'">
            <value cm="Complication" csd="SRT" cv="DD-60001" />
</xsl:when>
<xsl:when test="$causeofdeath = 'localdisease'">
            <value cm="Local disease" csd="SRT" cv="DF-00280" />
</xsl:when>
<xsl:when test="$causeofdeath = 'distantdisease'">
            <value cm="Distant metastases" csd="UMLS" cv="C3641061" />
</xsl:when>
<xsl:when test="$causeofdeath = 'localdistant'">
            <value cm="Local disease and distant metastases" csd="99PMP" cv="300010" />
</xsl:when>
<xsl:when test="$causeofdeath = 'unrelated'">
            <value cm="Intercurrent disease" csd="SRT" cv="DF-00170" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized causeofdeath <xsl:value-of select="$causeofdeath"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="postrttreatment" select="replace(normalize-space(lower-case(postrttreatment)),'[^a-z]','')"/>
<xsl:if test="string-length($postrttreatment) != 0 and not(matches($postrttreatment,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Post-radiotherapy treatment" csd="99PMP" cv="300011"/>
<xsl:choose>
<xsl:when test="$postrttreatment = 'yes'">
            <value cm="Yes" csd="SRT" cv="R-0038D" />
</xsl:when>
<xsl:when test="$postrttreatment = 'no'">
            <value cm="No" csd="SRT" cv="R-00339" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized postrttreatment <xsl:value-of select="$postrttreatment"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:variable name="dateofrecurrence" select="replace(normalize-space(lower-case(dateofrecurrence)),'[^0-9]','')"/>
<xsl:if test="string-length($dateofrecurrence) != 0">
		<date relationship="CONTAINS">
          <concept cm="Date of cancer recurrence" csd="LN" cv="63944-3" />
          <value><xsl:value-of select="$dateofrecurrence"/></value>
		</date>
</xsl:if>

<xsl:variable name="dateof2ndprimary" select="replace(normalize-space(lower-case(dateof2ndprimary)),'[^0-9]','')"/>
<xsl:if test="string-length($dateof2ndprimary) != 0">
		<date relationship="CONTAINS">
          <concept cm="Date of 2nd primary" csd="99PMP" cv="300012" />
          <value><xsl:value-of select="$dateof2ndprimary"/></value>
		</date>
</xsl:if>

<xsl:variable name="locationoffirstrecurrence" select="replace(normalize-space(lower-case(locationoffirstrecurrence)),'[^a-z]','')"/>
<xsl:if test="string-length($locationoffirstrecurrence) != 0 and not(matches($locationoffirstrecurrence,'unknown'))">
		<code relationship="CONTAINS">
          <concept cm="Location of first recurrence" csd="99PMP" cv="300013"/>
<xsl:choose>
<xsl:when test="$locationoffirstrecurrence = 'local'">
            <value cm="Local disease" csd="SRT" cv="DF-00280" />
</xsl:when>
<xsl:when test="$locationoffirstrecurrence = 'regional'">
            <value cm="Region" csd="SRT" cv="G-A16D" />
</xsl:when>
<xsl:when test="$locationoffirstrecurrence = 'distant'">
            <value cm="Distant metastases" csd="UMLS" cv="C3641061" />
</xsl:when>
<xsl:when test="$locationoffirstrecurrence = 'locoregional'">
            <value cm="Local and regional" csd="99PMP" cv="300014" />
</xsl:when>
<xsl:when test="$locationoffirstrecurrence = 'localdistant'">
            <value cm="Local disease and distant metastases" csd="99PMP" cv="300010" />
</xsl:when>
<xsl:when test="$locationoffirstrecurrence = 'both'">
            <value cm="Local disease and distant metastases" csd="99PMP" cv="300010" />		<!-- is that really what "both" means -->
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized locationoffirstrecurrence <xsl:value-of select="$locationoffirstrecurrence"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:if test="string-length(recurrencediff) != 0">
        <container continuity="SEPARATE" relationship="CONTAINS">
			<concept cm="Pathology of recurrent tumor" csd="99PMP" cv="300016" />
		
			<xsl:call-template name="pathology">
				<xsl:with-param name="diffparam"    select="recurrencediff"/>
				<xsl:with-param name="marginsparam" select="recurrencemargins"/>
				<xsl:with-param name="pniparam"     select="recurrencepni"/>
				<xsl:with-param name="iviparam"     select="recurrenceivi"/>
			</xsl:call-template>
		</container>
</xsl:if>

	  </container>

    </container>
  </DicomStructuredReportContent>
</DicomStructuredReport>


					</xsl:result-document>
					<xsl:choose>
						<!--<xsl:when test="doc-available($filename)">--> 	<!-- does not work -->
						<xsl:when test="unparsed-text-available($filename)">
							<xsl:message>Successfully wrote <xsl:value-of select="$filename"/></xsl:message>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>WARNING - Unsuccessfully wrote <xsl:value-of select="$filename"/></xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>WARNING - Have already done <xsl:value-of select="$filename"/> - assume duplicate row and same values :(</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="nodegroup">
		<xsl:param name="levelparam"/>
		<xsl:param name="levelsideparam"/>
		<xsl:param name="countparam"/>
		<xsl:param name="removedparam"/>
<!--<xsl:message>nodegroup template levelparam = <xsl:value-of select="$levelparam"/></xsl:message>-->
<!--<xsl:message>nodegroup template levelsideparam = <xsl:value-of select="$levelsideparam"/></xsl:message>-->

<xsl:variable name="count" select="replace(normalize-space(lower-case($countparam)),'[^0-9]','')"/>		<!-- remove 'x' for now, treat as blank :( -->
<xsl:variable name="removed" select="replace(normalize-space(lower-case($removedparam)),'[^0-9]','')"/>	<!-- remove 'x' for now, treat as blank :( -->
<!--<xsl:message>nodegroup template countparam = <xsl:value-of select="$countparam"/> count = <xsl:value-of select="$count"/></xsl:message>-->
<!--<xsl:message>nodegroup template removedparam = <xsl:value-of select="$removedparam"/> removed = <xsl:value-of select="$removed"/></xsl:message>-->

<xsl:if test="string-length($count) != 0 or string-length($removed) != 0">
            <code relationship="CONTAINS">
		      <concept cm="Cervical lymph node group" csd="SRT" cv="T-C4207" />
<xsl:choose>
<xsl:when test="$levelparam = '1'">
            <value cm="Level I - Submental and submandibular lymph node group" csd="99PMP" cv="300005" />
</xsl:when>
<xsl:when test="$levelparam = '2'">
            <value cm="Level II - Upper jugular lymph node group" csd="SRT" cv="T-C420B" />	<!-- SNOMED concepts are generic and do not include level in synomnym :( -->
</xsl:when>
<xsl:when test="$levelparam = '3'">
            <value cm="Level III - Middle jugular lymph node group" csd="SRT" cv="T-C420C" />
</xsl:when>
<xsl:when test="$levelparam = '4'">
            <value cm="Level IV - Lower jugular lymph node group" csd="SRT" cv="T-C420D" />
</xsl:when>
<xsl:when test="$levelparam = '5'">
            <value cm="Level V - Posterior triangle cervical lymph node group" csd="SRT" cv="T-C420E" />
</xsl:when>
<xsl:when test="$levelparam = 'other'">
            <value cm="Cervical lymph node outside level I through V" csd="99PMP" cv="300006" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized levelparam <xsl:value-of select="$levelparam"/></xsl:message>
</xsl:otherwise>
</xsl:choose>

              <code relationship="HAS CONCEPT MOD">
		        <concept cm="Sidedness" csd="SRT" cv="R-400D5" />
<xsl:choose>
<xsl:when test="$levelsideparam = 'ipsi'">
            <value cm="Ipsilateral" csd="SRT" cv="R-40356" />
</xsl:when>
<xsl:when test="$levelsideparam = 'contra'">
            <value cm="Contralateral" csd="SRT" cv="R-40357" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized levelsideparam <xsl:value-of select="$levelsideparam"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
		      </code>

<xsl:if test="string-length($removed) != 0">
            <num relationship="HAS PROPERTIES">
		      <concept cm="Number of nodes removed" csd="DCM" cv="111473" />
			  <value><xsl:value-of select="$removed"/></value>
			  <units cm="nodes" csd="UCUM" cv="{$nodeunitcodevalue}" />
		    </num>
</xsl:if>
<xsl:if test="string-length($count) != 0">
            <num relationship="HAS PROPERTIES">
		      <concept cm="Number of nodes positive" csd="DCM" cv="111474" />
			  <value><xsl:value-of select="$count"/></value>
			  <units cm="nodes" csd="UCUM" cv="{$nodeunitcodevalue}" />
		    </num>
</xsl:if>

		    </code>
</xsl:if>

	</xsl:template>

	<xsl:template name="biopsy">
		<xsl:param name="biopsydateparam"/>
		<xsl:param name="biopsylocationparam"/>
<!--<xsl:message>biopsy template date = <xsl:value-of select="$biopsydateparam"/></xsl:message>-->

<xsl:variable name="biopsydate" select="replace(normalize-space(lower-case($biopsydateparam)),'[^0-9]','')"/>
<xsl:variable name="biopsylocation" select="replace(normalize-space($biopsylocationparam),'[^a-zA-Z0-9 /,()-]','')"/>
<xsl:if test="string-length($biopsydate) != 0 or string-length($biopsylocation) != 0">
<!--<xsl:message>have biopsy values</xsl:message>-->
          <container continuity="SEPARATE" relationship="CONTAINS">
			<concept cm="Biopsy" csd="SRT" cv="P1-03100" />

<xsl:if test="string-length($biopsydate) != 0">
            <date relationship="CONTAINS">
		      <concept cm="Date of procedure" csd="SRT" cv="F-05045" />
			  <value><xsl:value-of select="$biopsydate"/></value>
		    </date>
</xsl:if>

<xsl:if test="string-length($biopsylocation) != 0">
            <text relationship="CONTAINS">								<!-- use text since too variable to code, and multiple sites in one string :( -->
		      <concept cm="Biopsy Site" csd="SRT" cv="F-04956" />
			  <value><xsl:value-of select="$biopsylocation"/></value>
		    </text>
</xsl:if>
          </container>
</xsl:if>

	</xsl:template>

	<xsl:template name="surgery">
		<xsl:param name="surgerydateparam"/>
		<xsl:param name="surgerydescparam"/>
		<xsl:param name="surgeryprimaryressectedparam"/>
		<xsl:param name="surgerynodedissectionparam"/>
<!--<xsl:message>surgery template date = <xsl:value-of select="$surgerydateparam"/></xsl:message>-->
		
<xsl:variable name="surgerydate" select="replace(normalize-space(lower-case($surgerydateparam)),'[^0-9]','')"/>
<xsl:variable name="surgerydesc" select="replace(normalize-space($surgerydescparam),'[^a-zA-Z0-9 /,()-]','')"/>
<xsl:variable name="surgeryprimaryressected" select="replace(normalize-space(lower-case($surgeryprimaryressectedparam)),'[^a-z]','')"/>
<xsl:variable name="surgerynodedissection" select="replace(normalize-space(lower-case($surgerynodedissectionparam)),'[^a-z]','')"/>
<xsl:if test="string-length($surgerydate) != 0 or string-length($surgerydesc) != 0 or string-length($surgeryprimaryressected) != 0 or string-length($surgerynodedissection) != 0">
<!--<xsl:message>have surgery values</xsl:message>-->
          <container continuity="SEPARATE" relationship="CONTAINS">
			<concept cm="Surgical Procedure" csd="SRT" cv="P0-009C3" />

<xsl:if test="string-length($surgerydate) != 0">
            <date relationship="CONTAINS">
		      <concept cm="Date of procedure" csd="SRT" cv="F-05045" />
			  <value><xsl:value-of select="$surgerydate"/></value>
		    </date>
</xsl:if>

<xsl:if test="string-length($surgerydesc) != 0">
            <text relationship="CONTAINS">
		      <concept cm="Procedure Description" csd="UMLS" cv="C0807506" />
			  <value><xsl:value-of select="$surgerydesc"/></value>
		    </text>
</xsl:if>

<xsl:if test="string-length($surgeryprimaryressected) != 0">	<!-- Yes, Partial, No -->
		<code relationship="CONTAINS">
          <concept cm="Resection of primary tumor" csd="99PMP" cv="300001" />
<xsl:choose>
<xsl:when test="$surgeryprimaryressected = 'yes'">
            <value cm="Complete excision" csd="SRT" cv="P1-03002" />	<!-- This isn't quite right, because strictly speaking it applies to the organ -->
</xsl:when>
<xsl:when test="$surgeryprimaryressected = 'partial'">
            <value cm="Partial excision" csd="SRT" cv="P1-03001" />
</xsl:when>
<xsl:when test="$surgeryprimaryressected = 'no'">
            <value cm="Not performed" csd="SRT" cv="R-4135B" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized surgeryprimaryressected <xsl:value-of select="$surgeryprimaryressected"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>

<xsl:if test="string-length($surgerynodedissection) != 0">	<!-- Yes, No -->
		<code relationship="CONTAINS">
          <concept cm="Block dissection of cervical lymph nodes" csd="SRT" cv="P1-65325" />
<xsl:choose>
<xsl:when test="$surgerynodedissection = 'yes'">
            <value cm="Performed" csd="SRT" cv="R-42514" />
</xsl:when>
<xsl:when test="$surgerynodedissection = 'no'">
            <value cm="Not performed" csd="SRT" cv="R-4135B" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized surgerynodedissection <xsl:value-of select="$surgerynodedissection"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
        </code>
</xsl:if>
          </container>
</xsl:if>
	</xsl:template>

	<xsl:template name="radiotherapy">
		<xsl:param name="rtstartdateparam"/>
		<xsl:param name="rtenddateparam"/>
		<xsl:param name="rtdoseparam"/>
		<xsl:param name="rtdoseperfractionparam"/>
		<xsl:param name="rtnotesparam"/>
<!--<xsl:message>radiotherapy template start date = <xsl:value-of select="$rtstartdateparam"/></xsl:message>-->
		
<xsl:variable name="rtstartdate" select="replace(normalize-space(lower-case($rtstartdateparam)),'[^0-9]','')"/>
<xsl:variable name="rtenddate"   select="replace(normalize-space(lower-case($rtenddateparam)),'[^0-9]','')"/>
<xsl:variable name="rtdose" select="replace(normalize-space(lower-case($rtdoseparam)),'[^0-9.]','')"/>
<xsl:variable name="rtdoseperfraction" select="replace(normalize-space(lower-case($rtdoseperfractionparam)),'[^0-9.]','')"/>
<xsl:variable name="rtnotes" select="replace(normalize-space($rtnotesparam),'[^a-zA-Z0-9 /,()-]','')"/>
<xsl:if test="string-length($rtstartdate) != 0 or string-length($rtenddate) != 0 or string-length($rtdose) != 0 or string-length($rtdoseperfraction) != 0 or string-length($rtnotes) != 0">
<!--<xsl:message>have radiotherapy values</xsl:message>-->

          <container continuity="SEPARATE" relationship="CONTAINS">
			<concept cm="Radiotherapy Procedure" csd="SRT" cv="P5-C0000" />

<xsl:if test="string-length($rtstartdate) != 0">
            <date relationship="CONTAINS">
		      <concept cm="Date treatment started" csd="SRT" cv="F-04C2B" />
			  <value><xsl:value-of select="$rtstartdate"/></value>
		    </date>
</xsl:if>

<xsl:if test="string-length($rtenddate) != 0">
            <date relationship="CONTAINS">
		      <concept cm="Date treatment stopped" csd="SRT" cv="F-04C2C" />
			  <value><xsl:value-of select="$rtenddate"/></value>
		    </date>
</xsl:if>

<xsl:if test="string-length($rtenddate) != 0">
            <num relationship="CONTAINS">
		      <concept cm="Total radiation dose delivered" csd="SRT" cv="R-007B0" />
			  <value><xsl:value-of select="$rtdose"/></value>
			  <units cm="Gy" csd="UCUM" cv="Gy" />
		    </num>
</xsl:if>

<xsl:if test="string-length($rtenddate) != 0">
            <num relationship="CONTAINS">
		      <concept cm="Radiation dose per fraction" csd="99PMP" cv="300002" />
			  <value><xsl:value-of select="$rtdoseperfraction"/></value>
			  <units cm="Gy" csd="UCUM" cv="Gy" />
		    </num>
</xsl:if>

<xsl:if test="string-length($rtnotes) != 0">
            <text relationship="CONTAINS">
		      <concept cm="Procedure Description" csd="UMLS" cv="C0807506" />
			  <value><xsl:value-of select="$rtnotes"/></value>
		    </text>
</xsl:if>
          </container>
</xsl:if>
	</xsl:template>
	
	<xsl:template name="chemotherapy">
		<xsl:param name="chemostartdateparam"/>
		<xsl:param name="chemoenddateparam"/>
		<xsl:param name="chemodrug1param"/>
		<xsl:param name="chemodrug2param"/>
		<xsl:param name="chemodrug3param"/>
<!--<xsl:message>chemotherapy template start date = <xsl:value-of select="$chemostartdateparam"/></xsl:message>-->
		
<xsl:variable name="chemostartdate" select="replace(normalize-space(lower-case($chemostartdateparam)),'[^0-9]','')"/>
<xsl:variable name="chemoenddate"   select="replace(normalize-space(lower-case($chemoenddateparam)),'[^0-9]','')"/>
<xsl:variable name="chemodrug1" select="replace(normalize-space(lower-case($chemodrug1param)),'[^a-z]','')"/>
<xsl:variable name="chemodrug2" select="replace(normalize-space(lower-case($chemodrug2param)),'[^a-z]','')"/>
<xsl:variable name="chemodrug3" select="replace(normalize-space(lower-case($chemodrug3param)),'[^a-z]','')"/>
<xsl:if test="string-length($chemostartdate) != 0 or string-length($chemoenddate) != 0 or string-length($chemodrug1) != 0 or string-length($chemodrug2) != 0 or string-length($chemodrug3) != 0">
<!--<xsl:message>have chemotherapy values</xsl:message>-->

          <container continuity="SEPARATE" relationship="CONTAINS">
			<concept cm="Chemotherapy" csd="SRT" cv="P0-0058E" />

<xsl:if test="string-length($chemostartdate) != 0">
            <date relationship="CONTAINS">
		      <concept cm="Date treatment started" csd="SRT" cv="F-04C2B" />
			  <value><xsl:value-of select="$chemostartdate"/></value>
		    </date>
</xsl:if>

<xsl:if test="string-length($chemoenddate) != 0">
            <date relationship="CONTAINS">
		      <concept cm="Date treatment stopped" csd="SRT" cv="F-04C2C" />
			  <value><xsl:value-of select="$chemoenddate"/></value>
		    </date>
</xsl:if>

<xsl:call-template name="chemotherapydrug">
	<xsl:with-param name="chemodrug" select="$chemodrug1"/>
</xsl:call-template>
<xsl:call-template name="chemotherapydrug">
	<xsl:with-param name="chemodrug" select="$chemodrug2"/>
</xsl:call-template>
<xsl:call-template name="chemotherapydrug">
	<xsl:with-param name="chemodrug" select="$chemodrug3"/>
</xsl:call-template>

          </container>
</xsl:if>
	</xsl:template>

	<xsl:template name="chemotherapydrug">
		<xsl:param name="chemodrug"/>
<!--<xsl:message>template chemotherapydrug chemodrug <xsl:value-of select="$chemodrug"/></xsl:message>-->
<xsl:if test="string-length($chemodrug) != 0 and not(contains($chemodrug,'unknown'))">
          <code relationship="CONTAINS">
            <concept cm="Antineoplastic agent" csd="SRT" cv="F-618AA" />
<xsl:choose>
<xsl:when test="$chemodrug = 'cetuximab'">
<!--<xsl:message>chemodrug is cetuximab</xsl:message>-->
            <value cm="Cetuximab" csd="SRT" cv="F-61F04" />
</xsl:when>
<xsl:when test="$chemodrug = 'platinum'">
<!--<xsl:message>chemodrug is platinum</xsl:message>-->
            <value cm="Platinum" csd="SRT" cv="C-15310" />
</xsl:when>
<xsl:when test="$chemodrug = 'taxane'">
<!--<xsl:message>chemodrug is taxane</xsl:message>-->
            <value cm="Taxane" csd="SRT" cv="C-3013D" />
</xsl:when>
<xsl:when test="$chemodrug = 'fivefu'">
<!--<xsl:message>chemodrug is taxane</xsl:message>-->
            <value cm="5FU" csd="SRT" cv="C-780F0" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized chemodrug <xsl:value-of select="$chemodrug"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
          </code>
</xsl:if>
	</xsl:template>
	
	<xsl:template name="pathology">
		<xsl:param name="diffparam"/>
		<xsl:param name="marginsparam"/>
		<xsl:param name="pniparam"/>
		<xsl:param name="iviparam"/>
		
<!--<xsl:message>template pathology diff <xsl:value-of select="$diffparam"/></xsl:message>-->
<xsl:variable name="diff" select="replace(normalize-space(lower-case($diffparam)),'[^a-z]','')"/>
<xsl:if test="string-length($diff) != 0">
      <container continuity="SEPARATE" relationship="CONTAINS">
        <concept cm="Pathology Results" csd="DCM" cv="111468" />		<!-- TID 4207 Breast Imaging Pathology Results as model -->

		<code relationship="CONTAINS">
          <concept cm="Pathology" csd="DCM" cv="111042" />
            <value cm="Squamous Cell Carcinoma" csd="SRT" cv="M-80703" />

<xsl:if test="string-length($diff) != 0 and not(matches($diff,'unknown'))">
<xsl:if test="not(matches($diff,'insitu'))">
            <code relationship="HAS PROPERTIES">
              <concept cm="Histological grade finding" csd="SRT" cv="F-02900" />	<!-- DCID 6070 Bloom-Richardson Histologic Grade, though not actually Bloom-Richardson, which is breast-specific, just ordinary AJCC -->
<xsl:choose>
<xsl:when test="$diff = 'well'">
            <value cm="Grade 1: well differentiated" csd="SRT" cv="G-F211" />
</xsl:when>
<xsl:when test="$diff = 'moderate'">
            <value cm="Grade 2: moderately differentiated" csd="SRT" cv="G-F212" />
</xsl:when>
<xsl:when test="$diff = 'poor'">
            <value cm="Grade 3: poorly differentiated" csd="SRT" cv="G-F213" />
</xsl:when>
<xsl:when test="$diff = 'undifferentiated'">
            <value cm="Grade 4: undifferentiated" csd="SRT" cv="R-41DC5" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized diff <xsl:value-of select="$diff"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
              <!--<code relationship="HAS CONCEPT MOD">
                <concept cm="Histologic grade" csd="SRT" cv="R-00258" />
				<value cm="" csd="" cv="" />
              </code>-->
            </code>
</xsl:if>	<!-- diff not insitu -->

            <code relationship="HAS PROPERTIES">
              <concept cm="Malignancy Type" csd="DCM" cv="111388" />
<xsl:choose>
<xsl:when test="$diff = 'insitu'">
            <value cm="Carcinoma in situ" csd="SRT" cv="D1-F3502" />
</xsl:when>
<xsl:otherwise>
            <value cm="Invasive carcinoma" csd="UMLS" cv="C1334274" />
</xsl:otherwise>
</xsl:choose>
            </code>
			
<xsl:variable name="margins" select="replace(normalize-space(lower-case($marginsparam)),'[^a-z]','')"/>
<xsl:if test="string-length($margins) != 0 and not(matches($margins,'unknown'))">
            <code relationship="HAS PROPERTIES">
              <concept cm="Tumor margin status" csd="SRT" cv="R-00274" />
<xsl:choose>
<xsl:when test="$margins = 'positive'">
            <value cm="Surgical margin involved by tumor" csd="SRT" cv="G-8DA4" />	<!-- TID 4207 uses (111471, DCM, "Involved"):( -->
</xsl:when>
<xsl:when test="$margins = 'close'">
            <value cm="Surgical margin close to tumor" csd="99PMP" cv="300004" />	<!-- ??? definition of "close" ?? :( -->
</xsl:when>
<xsl:when test="$margins = 'negative'">
            <value cm="Surgical margin uninvolved by tumor" csd="SRT" cv="M-09400" />	<!-- TID 4207 uses (111470, DCM, "Uninvolved") :( -->
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized margins <xsl:value-of select="$margins"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
            </code>
</xsl:if>	<!-- margins -->

<xsl:variable name="pni" select="replace(normalize-space(lower-case($pniparam)),'[^a-z]','')"/>
<xsl:if test="string-length($pni) != 0 and not(matches($pni,'unknown'))">
            <code relationship="HAS PROPERTIES">
              <concept cm="Perineural invasion finding" csd="SRT" cv="F-0369E" />
<xsl:choose>
<xsl:when test="$pni = 'yes'">
            <value cm="Perineural invasion by tumor present" csd="SRT" cv="G-F538" />
</xsl:when>
<xsl:when test="$pni = 'no'">
            <value cm="Perineural invasion by tumor absent" csd="SRT" cv="G-F7A3" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized pni <xsl:value-of select="$pni"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
            </code>
</xsl:if>	<!-- pni -->

<xsl:variable name="ivi" select="replace(normalize-space(lower-case($iviparam)),'[^a-z]','')"/>
<xsl:if test="string-length($ivi) != 0 and not(matches($pni,'unknown'))">
            <code relationship="HAS PROPERTIES">
              <concept cm="Status of vascular invasion by tumor" csd="SRT" cv="R-0026E" />	<!-- NB. SNOMED "vascular" has children of large and small vessels, and later includes lymphatic vessels -->
<xsl:choose>
<xsl:when test="$ivi = 'yes'">
            <value cm="Vascular invasion by tumor present" csd="SRT" cv="R-002A7" />
</xsl:when>
<xsl:when test="$ivi = 'no'">
            <value cm="Vascular invasion by tumor absent" csd="SRT" cv="G-F519" />
</xsl:when>
<xsl:otherwise>
<xsl:message>Unrecognized ivi <xsl:value-of select="$ivi"/></xsl:message>
</xsl:otherwise>
</xsl:choose>
            </code>
</xsl:if>	<!-- ivi -->

</xsl:if>	<!-- diff -->

        </code>
      </container>
</xsl:if>	<!-- primarydiff -->
	</xsl:template>

</xsl:stylesheet>

