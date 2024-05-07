for file in *.vcf*; do
	for sample in `bcftools query -l $file`; do
		bcftools view -c1 -Oz -s $sample -o ${file/.vcf*/-$sample.vcf} $file
	done
done

