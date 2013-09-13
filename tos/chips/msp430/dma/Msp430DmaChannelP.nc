/*
 * Copyright (c) 2011 Eric B. Decker
 * Copyright (c) 2005-2006 Arch Rock Corporation
 * Copyright (c) 2000-2005 The Regents of the University of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @author Ben Greenstein <ben@cs.ucla.edu>
 * @author Jonathan Hui <jhui@archrock.com>
 * @author Joe Polastre <info@moteiv.com>
 * @author Eric B. Decker <cire831@gmail.com>
 */

#include "Msp430Dma.h"

generic module Msp430DmaChannelP() {
  provides interface Msp430DmaChannel as Channel;
  uses interface HplMsp430DmaChannel as HplChannel;
}

implementation {
  async command error_t
    Channel.setupTransfer(uint16_t control,
			  dma_trigger_t trigger, 
			  uint16_t src_addr, 
			  uint16_t dst_addr, 
			  uint16_t size) {
    call HplChannel.setSrc(src_addr);
    call HplChannel.setDst(dst_addr);
    call HplChannel.setSize(size);
    call HplChannel.setTrigger(trigger);
    call HplChannel.setChannelControl(control);
    return SUCCESS;
  }
  
  async command error_t Channel.enableDma() {
    call HplChannel.enableDMA();
    return SUCCESS;
  }
  
  async command error_t
    Channel.repeatDma(uint16_t src_addr,
		      uint16_t dst_addr,
		      uint16_t size ) {
    call HplChannel.setSrc(src_addr);
    call HplChannel.setDst(dst_addr);
    call HplChannel.setSize(size);
    call HplChannel.enableDMA();
    return SUCCESS;
  }
  
  async command error_t Channel.softwareTrigger() {
    if (call HplChannel.getTrigger() != DMA_TRIGGER_DMAREQ) 
      return FAIL;
    call HplChannel.triggerDMA();
    return SUCCESS;
  }
  
  async command error_t Channel.stopDma() {
    uint16_t control;

    control = call HplChannel.getChannelControl();
    control &= DMADT_3;			/* isolate low two bits of DT field */
    if (control != DMA_DT_BURST_BLOCK)
      return FAIL;
    call HplChannel.disableDMA();
    return SUCCESS;
    
  }
  
  async event void HplChannel.transferDone() {
    signal Channel.transferDone();
  }

  default async event void Channel.transferDone() {}
}