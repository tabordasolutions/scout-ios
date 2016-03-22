/*|~^~|Copyright (c) 2008-2016, Massachusetts Institute of Technology (MIT)
 |~^~|All rights reserved.
 |~^~|
 |~^~|Redistribution and use in source and binary forms, with or without
 |~^~|modification, are permitted provided that the following conditions are met:
 |~^~|
 |~^~|-1. Redistributions of source code must retain the above copyright notice, this
 |~^~|ist of conditions and the following disclaimer.
 |~^~|
 |~^~|-2. Redistributions in binary form must reproduce the above copyright notice,
 |~^~|this list of conditions and the following disclaimer in the documentation
 |~^~|and/or other materials provided with the distribution.
 |~^~|
 |~^~|-3. Neither the name of the copyright holder nor the names of its contributors
 |~^~|may be used to endorse or promote products derived from this software without
 |~^~|specific prior written permission.
 |~^~|
 |~^~|THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 |~^~|AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 |~^~|IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 |~^~|DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 |~^~|FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 |~^~|DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 |~^~|SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 |~^~|CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 |~^~|OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 |~^~|OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\*/
/**
 *
 */
package edu.mit.ll.nics.android.formgen;

import android.content.res.Resources;
import android.graphics.Color;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.text.InputType;
import android.view.View.OnFocusChangeListener;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;
import edu.mit.ll.nics.android.fragments.FormFragment;

public class FormEditText extends FormWidget {
	protected TextView mLabel;
	protected EditText mInput;

	public FormEditText(FragmentActivity context, String property, String displayText, boolean enabled, int fontSize, OnFocusChangeListener listener,Fragment fragment) {
		super(context, property, displayText,fragment);

		mEnabled = enabled;
		
		if(mDisplayTextKey != null && !mDisplayTextKey.isEmpty())  {
			mLabel = new TextView(context);
			mLabel.setText(getDisplayText());
			mLabel.setLayoutParams(FormFragment.defaultLayoutParams);
			mLayout.addView(mLabel);
		}
		
		mInput = new EditText(context);
		mInput.setLayoutParams(FormFragment.defaultLayoutParams);
		mInput.setImeOptions(EditorInfo.IME_ACTION_NEXT);
		mInput.setEnabled(enabled);
		mInput.setOnFocusChangeListener(listener);
		mInput.setTag(property);
		
		if(!enabled) {
			mInput.setTextColor(Color.GRAY);
		}
		
		if(fontSize > -1) {
			mInput.setTextSize(fontSize);
		}

		mLayout.addView(mInput);
	}

	@Override
	public String getValue() {
		return mInput.getText().toString();
	}

	@Override
	public void setValue(String value) {
		mInput.setText(value);
	}

	@Override
	public void setHint(String value) {
		Resources res = mContext.getResources();
        int resId = res.getIdentifier(value, "string", mContext.getPackageName());
		mInput.setHint(res.getString(resId));
	}

	@Override
	public void setEditable(boolean isEditable) {
		mInput.setEnabled(isEditable);
		
		if(!isEditable) {
			mInput.setTextColor(Color.GRAY);
		} else {
			mInput.setTextColor(Color.WHITE);
		}
	}
}
