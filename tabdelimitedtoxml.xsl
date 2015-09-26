<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:output method="xml"/>
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
	
	<!-- See "http://stackoverflow.com/questions/16888651/batch-processing-tab-delimited-files-in-xslt" -->

	<xsl:template name="text2xml">
		<xsl:variable name="text" select="unparsed-text('filtered_IOWA_HN_qin_clinical_data_feb_05_2015.txt', 'iso-8859-1')"/>
		
		<xsl:variable name="header">
            <xsl:analyze-string select="$text" regex="(..*)">
                <xsl:matching-substring>
                    <xsl:if test="position()=1">
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:if>                   
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
		
		<xsl:variable name="headerTokens" select="tokenize($header,'\t')"/>
		
		<patients>
			<xsl:analyze-string select="$text" regex="(..*)">
				<xsl:matching-substring>
					<xsl:if test="matches(.,'^QIN-HEADNECK')">
						<patient>
							<xsl:analyze-string select="." regex="([^\t][^\t]*)\t?|\t">
								<xsl:matching-substring>
									<xsl:variable name="pos" select="position()"/>
									<xsl:variable name="usename" select="replace(normalize-space(lower-case($headerTokens[$pos])),'[^a-z0-9]','')"/>
									<!--<xsl:message>With usename = <xsl:value-of select="$usename"/></xsl:message>-->
									<xsl:element name="{$usename}">
									<!--<xsl:element name="XXX">-->
										<xsl:value-of select="normalize-space(regex-group(1))"/>
									</xsl:element>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</patient>
					</xsl:if>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</patients>

	</xsl:template>

</xsl:stylesheet>



