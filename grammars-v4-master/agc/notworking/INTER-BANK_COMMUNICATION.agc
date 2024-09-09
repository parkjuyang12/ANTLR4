### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	INTER-BANK_COMMUNICATION.agc
# Purpose:	Part of the source code for Solarium build 55. This
#		is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), for Apollo 4.
# Assembler:	yaYUL --block1
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
# Mod history:	2009-09-15 JL	Created.

## Page 290

# 	THE FOLLOWING SUBROUTINES ARE INTENDED TO FACILITATE INTER-BANK COMMUNICATION. ROUTINES ARE PROVIDED
# FOR JUMPING TO A LOCATION IN ANOTHER BANK, CALLING A SUBROUTINE IN ANOTHER BANK, AND OBTAINING DATA FROM ANOTHER
# BANK. IN ADDITION, A ROUTINE IS PROVIDED FOR MAKING UP A RETURN_ADDRESS CADR FOR USE BY THE CALLED SUBROUTINE.

		BANK	2
BANKCALL	TS	ADDRWD		# SUBROUTINE CALL WITH TRANSMISSION BOTH
		XCH	Q		# WAYS IN A. THE CADR OF THE CALLED
		AD	ONE		# ROUTINE SHOULD IMMEDIATELY FOLLOW THE
		TS	Q		# TC BANKCALL.
		INDEX	A
		CA	0 -1		# PICK UP CADR AND FALL INTO SWCALL.

SWCALL		TS	TEMQS		# SWCALL IS ALOS USED TO CALL SUBROUTINES
		XCH	BANKREG		# IN OTHER BANKS, BUT THE CADR ARRIVES IN
		TS	BANKTEM		# A. DATA MAY BE TRANSMITTED BACK TO THE
		XCH	Q		# CALLING PROGRAM IN A, HOWEVER. 
		XCH	TEMQS		# RETURN INFORMATION NOW COMPLETE.
		TS	ESCAPE
		MASK	70K		# PROVISION FOR CALLING A ROUTINE IN
		CCS	A		# FIXED-FIXED (OF QUESTIONABLE VALUE).
		TC	+2		# SPECIAL TREATMENT REQUIRED IF NON-ZERO.
		TC	+3		# INPUT CADR OK AS IS.

		CS	BANKREG		# FORM PROPER 12 BIT ADDRESS.
		AD	6K
 +3		AD	ESCAPE		# PROPER CADRS COME HERE WITH C(A) = 0.
		XCH	ADDRWD		# SO A CAN TRANSMIT WITH BANKCALL.
		INDEX	ADDRWD
		TC	0		# SETTING Q TO SWRETURN.

SWRETURN	XCH	BUF2 +1		# RETURN TO CALLER, TRANSMITTING THROUGH A
		TS	BANKREG
		XCH	BANKTEM		# RESTORE A AS UPON ARRIVAL TO SWRETURN.
		TC	TEMQS		# RETURN.

## Page 291

MAKECADR	CAF	ZERO		# LEAVES RETURN-ADDRESS CADR (AS SET BY
		AD	TEMQS		# SWCALL OR BANKCALL) IN ADDRWD.
		TS	ADDRWD
		AD	32K		# SEE IF BANK INFORMATION NEEDED (USUAL).
		TS	OVCTR
		TC	Q		# ADDRWD SET OK IF NO OVERFLOW (IN FF).

		XCH	OVCTR		# CONTAINS LOW 10 BITS ONLY.
		AD	BANKTEM
		TS	ADDRWD		# RETURN CADR NOW COMPLETE.
		TC	Q

32K		EQUALS	PRIO32
POSTJUMP	XCH	Q		# ONE-WAY BANK TO BANK JUMP, WITH NO
		INDEX	A		# RETURN ADDRESS. THIS VERSION TRANSMITS
		CAF	0		# THROUGH A IF DESIRED.

BANKJUMP	TS	BANKREG		# SAME AS ABOVE ONLY ADDRESS ARRIVES IN A.
		MASK	LOW10		# BANKJUMP AND POSTJUMP MAY BE USED IN
		XCH	Q		# INTERRUPT OR UNDER EXEC, BUT BANKCALL
		INDEX	Q		# AND SWCALL MAY BE USED ONLY UNDER EXEC.
		TC	6000


DATACALL	TS	ESCAPE		# SUBROUTINE TO RETRIEVE DATA IN ANOTHER
		XCH	BANKREG		# BANK. THE CADR OF THE LOCATION OF INTER-
		XCH	ESCAPE		# EST ARRIVES IN A AND ITS CONTENTS ARE IN
		MASK	LOW10		# A ON EXIT. THIS MAY BE USED ONLY UNDER
		INDEX	A		# EXECUTIVE.
		CAF	6000		# REQUESTED DATA NOW ACQUIRED.

		XCH	ESCAPE
		TS	BANKREG
		XCH	ESCAPE
		TC	Q

## Page 292

# 	THE FOLLOWING ROUTINES ARE INTERRUPT ANALOGS OF BANKCALL AND SWCALL. BANK-TO-BANK ONLY.

IBNKCALL	TS	RUPTREG1
		XCH	Q
		AD	ONE
		TS	Q
		INDEX	A
		CAF	0 -1

ISWCALL		TS	RUPTREG3
		XCH	BANKREG
		TS	RUPTREG2
		XCH	Q
		XCH	RUPTREG3
		MASK	LOW10
		XCH	RUPTREG1
		INDEX	RUPTREG1
		TC	6000

ISWRETRN	XCH	RUPTREG2
		TS	BANKREG
		XCH	RUPTREG2
		TC	RUPTREG3
