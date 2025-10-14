import React from 'react'
import { Document, Page, Text, View, StyleSheet, Font } from '@react-pdf/renderer'

// Define types for receipt data
export type PaymentReceiptData = {
  receipt_number: string
  household_name: string
  residence_unit: string
  amount_paid: number
  payment_method: string
  payment_reference?: string
  payment_date: string
  received_by: string
  tenant_name?: string
  invoice_numbers?: string[]
  notes?: string
}

// Create styles
const styles = StyleSheet.create({
  page: {
    padding: 40,
    fontSize: 11,
    fontFamily: 'Helvetica',
  },
  header: {
    marginBottom: 20,
    textAlign: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
  },
  receiptNumber: {
    fontSize: 12,
    color: '#333',
    marginBottom: 5,
  },
  section: {
    marginBottom: 15,
    padding: 10,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 4,
  },
  sectionTitle: {
    fontSize: 12,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#333',
    textTransform: 'uppercase',
  },
  row: {
    flexDirection: 'row',
    marginBottom: 5,
  },
  label: {
    width: '40%',
    fontSize: 10,
    color: '#666',
  },
  value: {
    width: '60%',
    fontSize: 10,
    color: '#000',
    fontWeight: 'bold',
  },
  amountSection: {
    marginTop: 10,
    marginBottom: 15,
    padding: 15,
    backgroundColor: '#f5f5f5',
    borderWidth: 2,
    borderColor: '#333',
    borderRadius: 4,
  },
  amountLabel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 5,
  },
  amountValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
  },
  invoiceList: {
    marginTop: 5,
  },
  invoiceItem: {
    fontSize: 9,
    color: '#666',
    marginBottom: 3,
    paddingLeft: 10,
  },
  footer: {
    marginTop: 30,
    paddingTop: 15,
    borderTopWidth: 1,
    borderTopColor: '#e0e0e0',
  },
  footerText: {
    fontSize: 9,
    color: '#999',
    textAlign: 'center',
    marginBottom: 3,
  },
  signature: {
    marginTop: 40,
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: '#333',
    width: '50%',
  },
  signatureLabel: {
    fontSize: 9,
    color: '#666',
    textAlign: 'center',
  },
  notes: {
    marginTop: 10,
    padding: 10,
    backgroundColor: '#fffbea',
    borderWidth: 1,
    borderColor: '#f59e0b',
    borderRadius: 4,
  },
  notesLabel: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#92400e',
    marginBottom: 5,
  },
  notesText: {
    fontSize: 9,
    color: '#78350f',
  },
  watermark: {
    position: 'absolute',
    fontSize: 60,
    color: '#f0f0f0',
    transform: 'rotate(-45deg)',
    top: '40%',
    left: '20%',
    opacity: 0.3,
  },
})

export function PaymentReceipt({ data }: { data: PaymentReceiptData }) {
  const formattedDate = new Date(data.payment_date).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  const formattedAmount = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(data.amount_paid)

  return (
    <Document>
      <Page size="A4" style={styles.page}>
        {/* Watermark */}
        <Text style={styles.watermark}>PAID</Text>

        {/* Header */}
        <View style={styles.header}>
          {data.tenant_name && <Text style={styles.subtitle}>{data.tenant_name}</Text>}
          <Text style={styles.title}>PAYMENT RECEIPT</Text>
          <Text style={styles.receiptNumber}>Receipt No: {data.receipt_number}</Text>
          <Text style={styles.receiptNumber}>Date: {formattedDate}</Text>
        </View>

        {/* Household Information */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Paid By</Text>
          <View style={styles.row}>
            <Text style={styles.label}>Household:</Text>
            <Text style={styles.value}>{data.household_name}</Text>
          </View>
          <View style={styles.row}>
            <Text style={styles.label}>Unit:</Text>
            <Text style={styles.value}>{data.residence_unit}</Text>
          </View>
        </View>

        {/* Payment Details */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Payment Details</Text>
          <View style={styles.row}>
            <Text style={styles.label}>Payment Method:</Text>
            <Text style={styles.value}>{data.payment_method.replace('_', ' ').toUpperCase()}</Text>
          </View>
          {data.payment_reference && (
            <View style={styles.row}>
              <Text style={styles.label}>Reference:</Text>
              <Text style={styles.value}>{data.payment_reference}</Text>
            </View>
          )}
          {data.invoice_numbers && data.invoice_numbers.length > 0 && (
            <>
              <View style={styles.row}>
                <Text style={styles.label}>Invoice(s) Paid:</Text>
              </View>
              <View style={styles.invoiceList}>
                {data.invoice_numbers.map((invNum, idx) => (
                  <Text key={idx} style={styles.invoiceItem}>
                    • {invNum}
                  </Text>
                ))}
              </View>
            </>
          )}
        </View>

        {/* Amount Paid */}
        <View style={styles.amountSection}>
          <Text style={styles.amountLabel}>Amount Paid</Text>
          <Text style={styles.amountValue}>{formattedAmount}</Text>
        </View>

        {/* Notes */}
        {data.notes && (
          <View style={styles.notes}>
            <Text style={styles.notesLabel}>Notes:</Text>
            <Text style={styles.notesText}>{data.notes}</Text>
          </View>
        )}

        {/* Signature */}
        <View style={styles.signature}>
          <Text style={styles.signatureLabel}>Received by: {data.received_by}</Text>
        </View>

        {/* Footer */}
        <View style={styles.footer}>
          <Text style={styles.footerText}>
            This is an official receipt for payment received.
          </Text>
          <Text style={styles.footerText}>
            Thank you for your payment.
          </Text>
          <Text style={styles.footerText}>
            Generated on {new Date().toLocaleString('en-US')}
          </Text>
        </View>
      </Page>
    </Document>
  )
}

// Helper function to generate receipt (used in Server Actions)
export function generatePaymentReceipt(data: PaymentReceiptData): React.ReactElement {
  return <PaymentReceipt data={data} />
}
