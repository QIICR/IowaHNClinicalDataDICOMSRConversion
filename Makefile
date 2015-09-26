PATHTOROOT = ${HOME}/work/pixelmed/imgbook

TAR = gnutar
#TAR = tar
COMPRESS = bzip2
COMPRESSEXT = bz2

FILESTOARCHIVE = \
	Makefile \
	tabdelimitedtoxml.xsl \
	clinicaldataxmltodicomsrxml.xsl \
	dicomsrfiles/ \
	dcsrdumpdicomsrfiles/ \
	filtered_IOWA_HN_qin_clinical_data_feb_05_2015.txt

all:	dicomsrfiles dcsrdumpdicomsrfiles dciodvfydicomsrfiles validatesrfiles

clean:
	rm -f clinicaldata.xml
	rm -rf patientxmlfiles
	rm -rf dicomsrfiles
	rm -rf dcsrdumpdicomsrfiles
	rm -rf dciodvfydicomsrfiles
	rm -rf validatesrfiles
	rm -f .exclude.list

clinicaldata.xml:	tabdelimitedtoxml.xsl filtered_IOWA_HN_qin_clinical_data_feb_05_2015.txt
	rm -f $@
	java -jar /opt/local/share/java/saxon9he.jar -xsl:tabdelimitedtoxml.xsl -o:$@ -it:text2xml
	mv $@ $@.bak
	sed -e 's/\([0-9][0-9]\)[/]\([0-9][0-9]\)[/]\([0-9][0-9][0-9][0-9]\)/\3-\1-\2/' <$@.bak >$@
	#diff $@.bak $@
	rm $@.bak

patientxmlfiles:	clinicaldataxmltodicomsrxml.xsl clinicaldata.xml
	rm -rf patientxmlfiles
	mkdir -p patientxmlfiles
	java -jar /opt/local/share/java/saxon9he.jar -xsl:clinicaldataxmltodicomsrxml.xsl -s:clinicaldata.xml

dicomsrfiles:	patientxmlfiles
	rm -rf dicomsrfiles
	mkdir -p dicomsrfiles
	#for i in `ls patientxmlfiles/*.xml | head -1`; do
	for i in patientxmlfiles/*.xml; do \
		echo "Doing $$i"; \
		java -cp ${PATHTOROOT} com.pixelmed.dicom.XMLRepresentationOfStructuredReportObjectFactory \
			toDICOM \
			$$i > dicomsrfiles/`basename $$i .xml`.dcm; \
	done

dcsrdumpdicomsrfiles:	dicomsrfiles
	rm -rf dcsrdumpdicomsrfiles
	mkdir -p dcsrdumpdicomsrfiles
	for i in dicomsrfiles/*.dcm; do \
		echo "Doing $$i"; \
		dcsrdump -identifier $$i >dcsrdumpdicomsrfiles/`basename $$i .dcm`.dcsrdump.txt 2>&1; \
	done

dciodvfydicomsrfiles:	dicomsrfiles
	rm -rf dciodvfydicomsrfiles
	mkdir -p dciodvfydicomsrfiles
	for i in dicomsrfiles/*.dcm; do \
		echo "Doing $$i"; \
		dciodvfy $$i >dciodvfydicomsrfiles/`basename $$i .dcm`.dciodvfy.txt 2>&1; \
	done

dcentvfydicomsrfiles:	dicomsrfiles
	dcentvfy dicomsrfiles/*.dcm

validatesrfiles:	dicomsrfiles
	rm -rf validatesrfiles
	mkdir -p validatesrfiles
	for i in dicomsrfiles/*.dcm; do \
		echo "Doing $$i"; \
		DicomSRValidator.sh $$i >validatesrfiles/`basename $$i .dcm`.validatesr.txt 2>&1; \
	done

xmldicomsrfiles:	dicomsrfiles
	rm -rf xmldicomsrfiles
	mkdir -p xmldicomsrfiles
	for i in dicomsrfiles/*.dcm; do \
		echo "Doing $$i"; \
		java -cp .:${PATHTOROOT} com.pixelmed.dicom.XMLRepresentationOfStructuredReportObjectFactory toXML $$i >xmldicomsrfiles/`basename $$i .dcm`.xml 2>&1; \
	done

MergeXMLDocuments.class:	MergeXMLDocuments.java
	javac $<

mergexmldicomsrfiles:	MergeXMLDocuments.class
	#java -cp . MergeXMLDocuments xmldicomsrfiles/*.xml
	java -cp . MergeXMLDocuments xmldicomsrfiles/QIN-HEADNECK-01-0003.xml xmldicomsrfiles/QIN-HEADNECK-01-0004.xml xmldicomsrfiles/QIN-HEADNECK-01-0006.xml

.exclude.list:	Makefile
	echo "Making .exclude.list"
	echo ".DS_Store" > $@
	echo ".directory" >> $@
	find . -path '*/CVS*' | sed 's/[.][/]//' >>$@

archive:	.exclude.list
	export COPYFILE_DISABLE=true; \
	export COPY_EXTENDED_ATTRIBUTES_DISABLE=true; \
	${TAR} -cv -X .exclude.list -f - ${FILESTOARCHIVE} | ${COMPRESS} > IowaHNClinicalDataDICOMSRConversion_`date +%Y%m%d%H%M%S`.tar.${COMPRESSEXT}
